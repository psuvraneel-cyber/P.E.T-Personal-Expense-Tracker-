/// Confidence scoring module — weighted feature-vector approach to quantify
/// how certain the parser is that an SMS is a real transaction.
///
/// ## Scoring Model
/// Score = sum of weighted features, clamped to [0, 100].
///
/// ### Feature Weights (calibrated conservatively)
///
/// | Feature                    | Weight | Rationale                           |
/// |---------------------------|--------|-------------------------------------|
/// | Debit/credit keyword      | +20    | Core intent signal, always present  |
/// | Amount extracted          | +15    | Required for transaction            |
/// | Bank identified           | +10    | Confirms financial institution      |
/// | Merchant identified       | +12    | Confirms counterparty               |
/// | UPI ID found              | +12    | Strong UPI transaction evidence     |
/// | Reference ID found        | +15    | Very strong — unique txn identifier |
/// | Account tail found        | +8     | Confirms user's account             |
/// | UPI/IMPS/NEFT keyword     | +8     | Confirms payment channel            |
/// | Trusted sender (AD-/VM-)  | +5     | Sender is a known bank              |
/// | Date extracted            | +5     | Temporal grounding                  |
///
/// ### Penalties
///
/// | Condition                  | Weight | Rationale                           |
/// |---------------------------|--------|-------------------------------------|
/// | Unknown bank              | -5     | Less certainty about source         |
/// | Unknown merchant          | -3     | Can't identify counterparty         |
/// | Promotional sender prefix | -10    | Higher false positive risk          |
/// | Very short body (<60ch)   | -5     | Less context to verify              |
///
/// ### Thresholds
/// - **≥ 55**: Accept as transaction (high confidence)
/// - **35–54**: Uncertain — surface for user verification
/// - **< 35**: Reject (too little evidence)
///
/// ### Calibration Strategy
/// 1. Start with conservative weights (current values).
/// 2. Run against labeled test dataset (20+ examples).
/// 3. Target: 100% precision on NON-TRANSACTION labels at threshold 55.
/// 4. Accept lower recall (missing some transactions) over false positives.
/// 5. For credits specifically, add a +5 threshold bias (require 60 to
///    auto-accept) because false positive credits are worse than false
///    positive debits (user sees phantom income).
///
/// ### Credit Bias
/// Credits are more dangerous as false positives because:
/// - Users may think they received money they didn't
/// - Budget calculations would be wrong
/// - Trust in the app decreases
///
/// Therefore, credits require confidence ≥ 60 (vs 55 for debits).
library;

import 'package:pet/services/sms_parser/negative_filter.dart';
import 'package:pet/services/sms_parser/transaction_parse_result.dart';

/// Confidence scoring configuration.
///
/// All weights and thresholds are configurable to allow tuning
/// without code changes (e.g., from remote config or A/B testing).
class ScoringConfig {
  // Feature weights (positive)
  final int wIntentKeyword;
  final int wAmount;
  final int wBank;
  final int wMerchant;
  final int wUpiId;
  final int wReferenceId;
  final int wAccountTail;
  final int wPaymentChannel;
  final int wTrustedSender;
  final int wDate;

  // Penalties (negative)
  final int pUnknownBank;
  final int pUnknownMerchant;
  final int pPromoSender;
  final int pShortBody;

  // Thresholds
  final int acceptThreshold;
  final int uncertainThreshold;

  /// Extra threshold added for credit transactions.
  /// Credits need higher confidence to avoid false positive income.
  final int creditBias;

  const ScoringConfig({
    this.wIntentKeyword = 20,
    this.wAmount = 15,
    this.wBank = 10,
    this.wMerchant = 12,
    this.wUpiId = 12,
    this.wReferenceId = 15,
    this.wAccountTail = 8,
    this.wPaymentChannel = 8,
    this.wTrustedSender = 5,
    this.wDate = 5,
    this.pUnknownBank = -5,
    this.pUnknownMerchant = -3,
    this.pPromoSender = -10,
    this.pShortBody = -5,
    this.acceptThreshold = 55,
    this.uncertainThreshold = 35,
    this.creditBias = 5,
  });

  /// Maximum possible score (all positive features present, no penalties).
  int get maxPossibleScore =>
      wIntentKeyword +
      wAmount +
      wBank +
      wMerchant +
      wUpiId +
      wReferenceId +
      wAccountTail +
      wPaymentChannel +
      wTrustedSender +
      wDate;
}

/// Score breakdown for debugging/telemetry.
class ScoreBreakdown {
  final int totalScore;
  final List<String> contributions;
  final bool isAccepted;
  final bool isUncertain;
  final int effectiveThreshold;

  const ScoreBreakdown({
    required this.totalScore,
    required this.contributions,
    required this.isAccepted,
    required this.isUncertain,
    required this.effectiveThreshold,
  });
}

/// Confidence scorer for parsed SMS transactions.
class ConfidenceScorer {
  ConfidenceScorer._();

  /// Default scoring configuration.
  static const ScoringConfig defaultConfig = ScoringConfig();

  /// UPI/IMPS/NEFT/RTGS indicator for payment channel bonus.
  static final RegExp _paymentChannelPattern = RegExp(
    r'\b(?:UPI|IMPS|NEFT|RTGS|BHIM)\b',
    caseSensitive: false,
  );

  /// Calculate confidence score and determine accept/reject/uncertain.
  ///
  /// Parameters reflect what was extracted in earlier pipeline stages.
  /// Each parameter's presence/absence contributes to the score.
  static ScoreBreakdown score({
    required bool hasIntentKeyword,
    required bool hasAmount,
    required String bankName,
    required String merchantName,
    required String? upiId,
    required String? referenceId,
    required String? accountTail,
    required DateTime? date,
    required String smsBody,
    required SenderTrust senderTrust,
    required TransactionDirection? direction,
    TransactionSubType subType = TransactionSubType.unknown,
    ScoringConfig config = defaultConfig,
  }) {
    int total = 0;
    final contributions = <String>[];

    // ── Positive features ────────────────────────────────────────

    if (hasIntentKeyword) {
      total += config.wIntentKeyword;
      contributions.add('+${config.wIntentKeyword} intent keyword');
    }

    if (hasAmount) {
      total += config.wAmount;
      contributions.add('+${config.wAmount} amount extracted');
    }

    if (bankName != 'Unknown Bank') {
      total += config.wBank;
      contributions.add('+${config.wBank} bank identified ($bankName)');
    }

    if (merchantName != 'Unknown') {
      total += config.wMerchant;
      contributions.add(
        '+${config.wMerchant} merchant identified ($merchantName)',
      );
    }

    if (upiId != null) {
      total += config.wUpiId;
      contributions.add('+${config.wUpiId} UPI ID found ($upiId)');
    }

    if (referenceId != null) {
      total += config.wReferenceId;
      contributions.add(
        '+${config.wReferenceId} reference ID found ($referenceId)',
      );
    }

    if (accountTail != null) {
      total += config.wAccountTail;
      contributions.add(
        '+${config.wAccountTail} account tail found (XX$accountTail)',
      );
    }

    if (_paymentChannelPattern.hasMatch(smsBody)) {
      total += config.wPaymentChannel;
      contributions.add('+${config.wPaymentChannel} payment channel keyword');
    }

    if (senderTrust == SenderTrust.transactional) {
      total += config.wTrustedSender;
      contributions.add('+${config.wTrustedSender} trusted sender prefix');
    }

    if (date != null) {
      total += config.wDate;
      contributions.add('+${config.wDate} date extracted');
    }

    if (subType == TransactionSubType.cashback ||
        subType == TransactionSubType.refund) {
      total += 5;
      contributions.add('+5 explicit cashback/refund bonus');
    }

    // ── Penalties ────────────────────────────────────────────────

    if (bankName == 'Unknown Bank') {
      total += config.pUnknownBank; // negative value
      contributions.add('${config.pUnknownBank} unknown bank');
    }

    if (merchantName == 'Unknown') {
      if (subType != TransactionSubType.cashback &&
          subType != TransactionSubType.refund) {
        total += config.pUnknownMerchant;
        contributions.add('${config.pUnknownMerchant} unknown merchant');
      } else {
        contributions.add('0 merchant penalty skipped (refund/cashback)');
      }
    }

    if (senderTrust == SenderTrust.promotional) {
      total += config.pPromoSender;
      contributions.add('${config.pPromoSender} promotional sender');
    }

    if (smsBody.length < 60) {
      total += config.pShortBody;
      contributions.add(
        '${config.pShortBody} short body (${smsBody.length} chars)',
      );
    }

    // Clamp to [0, 100]
    total = total.clamp(0, 100);

    // ── Apply credit bias ────────────────────────────────────────
    final effectiveThreshold = direction == TransactionDirection.credit
        ? config.acceptThreshold + config.creditBias
        : config.acceptThreshold;

    final isAccepted = total >= effectiveThreshold;
    final isUncertain = !isAccepted && total >= config.uncertainThreshold;

    contributions.add(
      '= $total (threshold: $effectiveThreshold'
      '${direction == TransactionDirection.credit ? " [+${config.creditBias} credit bias]" : ""})',
    );

    return ScoreBreakdown(
      totalScore: total,
      contributions: contributions,
      isAccepted: isAccepted,
      isUncertain: isUncertain,
      effectiveThreshold: effectiveThreshold,
    );
  }
}
