# SMS Transaction Parser — Integration Guide

## Architecture Summary (≤300 words)

The parser uses a **7-stage pipeline** with intent-first design, scoring every
SMS on a 0–100 int confidence scale. Stages are isolated Dart classes, each
independently testable.

**Pipeline**: `Preprocess → Negative Filters → Intent Detection → Amount
Extraction → Entity Extraction → Confidence Scoring → Decision`

**Negative Filter** (12 static rules) rejects OTPs, promos, scams, loans, KYC,
mandate setups, payment reminders, and app-download pushes *before* any regex
parsing. Uses TRAI sender-prefix conventions (AD-/VM- = transactional; VK-/HP-
= promotional).

**Intent Detector** looks for *completed* debit/credit keywords
("debited"/"credited"/"paid"/"sent"/"received") and validates that a currency
indicator (Rs/₹/INR) exists nearby. Positional precedence resolves conflicts
(first keyword wins). Refund/cashback override direction to credit.

**Amount Extractor** handles Rs/INR/₹, Indian comma notation (1,00,000.50),
excludes balance amounts ("Avl Bal"), and enforces ₹0.01–₹1Cr sanity bounds.

**Entity Extractor** pulls bank (sender map 35+ → body map 30+), UPI VPA
(validated against 60+ known handles), reference ID (4 patterns), merchant (9
cascading rules), account tail, and date (4 formats).

**Confidence Scorer** aggregates 10 positive feature weights and 4 penalties.
Thresholds: ≥55 accept (≥60 for credits due to +5 credit bias), 35–54
uncertain, <35 reject.

**Batch Parser** supports isolate offloading via `Isolate.run` for 5k+ SMS,
SHA-256 dedup, and incremental processing (only new messages).

**Kotlin NotificationListenerService** captures UPI-app notifications (25
whitelisted packages) and forwards to Dart via EventChannel for real-time
detection without SMS permission.

---

## Play Store Permission Wording & Consent Screen Text

### `AndroidManifest.xml` Permission Declaration

```xml
<!-- Required for reading historical bank SMS for transaction detection -->
<uses-permission android:name="android.permission.READ_SMS" />
<!-- Required for real-time incoming SMS detection -->
<uses-permission android:name="android.permission.RECEIVE_SMS" />
```

### Play Store Declaration Form Text

> **Core functionality**: P.E.T (Personal Expense Tracker) reads SMS messages
> to automatically detect UPI/bank transactions and categorize expenses. This
> is the default SMS handler's core functionality — automatic expense tracking
> from bank transaction SMS.
>
> **Scope of access**: The app reads only transactional SMS from known bank
> sender IDs (e.g., AD-HDFCBK, AD-SBIINB). Personal conversations and
> non-financial SMS are not read, processed, or stored.
>
> **Data handling**: SMS bodies are processed on-device only. No SMS content
> is transmitted to any server. Transaction data (amount, merchant, date) is
> stored locally in an encrypted SQLite database.
>
> **User control**: Users can disable SMS reading at any time from
> Settings → Permissions. Previously imported transactions remain available
> but no new SMS will be processed.

### In-App Consent Screen Text

```
📱 SMS Permission Required

P.E.T needs to read your bank SMS to automatically track
expenses and income. Here's what we do:

✅ Read only bank transaction SMS (e.g., "Rs 500 debited...")
✅ Process everything on your device — nothing leaves your phone
✅ Store only the transaction details, not the full SMS

❌ We never read personal messages
❌ We never upload SMS content to any server
❌ We never share your data with third parties

You can disable this anytime in Settings → Permissions.

[Allow SMS Access]    [Not Now]
```

### Notification Access Consent (for NotificationListenerService)

```
🔔 Notification Access (Optional)

P.E.T can also detect transactions from UPI app notifications
(Google Pay, PhonePe, Paytm, etc.) without needing SMS access.

✅ Captures notification text from financial apps only
✅ Processes on-device — no data transmitted
✅ Works alongside or instead of SMS reading

[Enable Notification Access]    [Skip]
```

---

## Integration Checklist (10 Steps)

### 1. Add Dependencies
Ensure `crypto: ^3.0.6` is in `pubspec.yaml` (already present).
No other new dependencies needed — the parser is pure Dart.

### 2. Register NotificationListenerService
Add to `AndroidManifest.xml` inside `<application>`:
```xml
<service
    android:name=".TransactionNotificationListener"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="false">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

### 3. Wire EventChannel for Notifications
In `SmsReaderPlugin.kt`, register a second EventChannel:
```kotlin
val notifChannel = EventChannel(
    flutterEngine.dartExecutor.binaryMessenger,
    "com.pet.tracker/notification_transactions"
)
notifChannel.setStreamHandler(TransactionNotificationListener.streamHandler)
```

### 4. Replace Parser Calls in SmsService
In `lib/services/sms_service.dart`, replace calls to the old
`TransactionParser.parseMessage()` with:
```dart
import 'package:pet/services/sms_parser/sms_parser.dart';

final result = SmsTransactionParser.parse(
  body: sms.body,
  sender: sms.sender,
  timestamp: sms.date,
);
if (result.isTransaction) {
  // Save to DB (map result fields to SmsTransaction model)
} else if (result.isUncertain) {
  // Surface for user verification in a "Review" tab
}
```

### 5. Update Background Worker
In `lib/services/sms_background_service.dart`, use `BatchParser`:
```dart
final results = await BatchParser.parseInIsolate(
  messages: rawMessages,
  lastProcessedTimestamp: prefs.getInt('lastSmsTimestamp') ?? 0,
  existingHashes: existingHashSet,
);
```

### 6. Add User Feedback UI
Add "Not a transaction" / "Mark as debit" / "Mark as credit" buttons
to the transaction detail screen. Wire to `UserFeedbackStore`:
```dart
UserFeedbackStore.recordFeedback(
  smsBody: transaction.rawSmsBody,
  smsTimestamp: transaction.smsTimestamp,
  action: UserFeedbackAction.notTransaction,
);
```

### 7. Load Feedback on Startup
In your app initialization:
```dart
final feedbackRecords = await db.queryAllFeedback();
UserFeedbackStore.loadFromRecords(feedbackRecords);
```

### 8. Run Unit Tests
```bash
flutter test test/sms_transaction_parser_test.dart
```
All 50+ assertions should pass. Fix any bank-specific regex mismatches
against your real SMS corpus.

### 9. Calibrate Confidence Thresholds
Run the parser against 100+ real SMS from your device:
```dart
for (final sms in realSmsCorpus) {
  final r = SmsTransactionParser.parse(
    body: sms.body, sender: sms.sender, timestamp: sms.date,
  );
  print('${r.confidence} ${r.isTransaction} ${r.isUncertain} | ${sms.body.substring(0, 50)}');
}
```
If false positives appear at threshold 55, raise to 60.
If too many real transactions are missed, lower to 50.

### 10. Submit for Play Store Review
- Complete the SMS/Call Log permission declaration form
- Use the consent screen text from above
- Submit a video demonstrating the consent flow
- Document that SMS is processed on-device only

---

## Confidence Scoring Breakdown

| Feature                    | Weight | Signal Type |
|---------------------------|--------|-------------|
| Debit/credit keyword      | +20    | Intent      |
| Amount extracted          | +15    | Financial   |
| Reference ID found        | +15    | Identity    |
| Merchant identified       | +12    | Context     |
| UPI ID found              | +12    | Context     |
| Bank identified           | +10    | Context     |
| Payment channel (UPI/IMPS)| +8     | Context     |
| Account tail found        | +8     | Identity    |
| Trusted sender (AD-/VM-)  | +5     | Sender      |
| Date extracted            | +5     | Temporal    |
| **Max possible**          | **110**| (clamped)   |

| Penalty                    | Weight | Mitigation  |
|---------------------------|--------|-------------|
| Unknown bank              | -5     | Less trust  |
| Unknown merchant          | -3     | Minor       |
| Promotional sender prefix | -10    | High risk   |
| Very short body (<60ch)   | -5     | Less data   |

| Decision         | Score Range | Action              |
|-----------------|-------------|---------------------|
| **Accept**      | ≥ 55 (60 for credits) | Save as transaction |
| **Uncertain**   | 35–54       | Show "Verify?"      |
| **Reject**      | < 35        | Discard silently    |

---

## Known Limitations & Next Steps

### Current Limitations

1. **English only**: The parser handles English-language bank SMS only.
   Hindi/regional language SMS (growing in SBI/PNB ecosystem) are not
   supported. ~5% of Indian bank SMS may be in Hindi.

2. **No ML model**: Pure regex + heuristic approach. An ML-based binary
   classifier would improve precision on edge cases (see next steps).

3. **No card transaction SMS**: Credit card statement SMS ("Your CC XX1234
   has been charged Rs 5000 at Amazon") use different templates. The current
   parser may partially handle them but is not optimized for card-specific
   patterns.

4. **NotificationListenerService reliability**: Some OEMs (Xiaomi, Oppo,
   Vivo) aggressively kill background services. The notification listener
   may stop working after device restart without manual "battery exempt"
   configuration by the user.

5. **Mandate vs. auto-pay confusion**: "Si/Mandate" setup SMS mentions
   amounts but is not a transaction. The mandate filter handles this, but
   some banks phrase it as "Rs X debited for mandate," which may slip
   through.

6. **Multi-account SMS**: If a user has two accounts at the same bank and
   both send SMS to the same phone, the parser cannot distinguish which
   account was used beyond the last 4 digits.

7. **Amount edge cases**: Some banks use "AMT" abbreviation instead of
   "Rs"/"INR" — not all abbreviations are covered.

8. **Timing of background processing**: WorkManager's minimum interval is
   15 minutes. Transactions detected via background scan may appear with
   up to 15-minute delay.

### Next Steps

1. **Binary classifier approach** (Requirement 15):
   - Extract 8–10 features: `hasDebitWord`, `hasCreditWord`, `hasAmount`,
     `hasRef`, `hasUpiId`, `hasBankSender`, `hasOtpWord`, `hasPromoWord`,
     `bodyLength`, `senderTrust`
   - Train a logistic regression or decision tree on 500+ labeled SMS
   - Use the model as a second opinion: if regex says YES but model says
     NO (or vice versa), mark as uncertain
   - Ship model weights as a Dart constant array (no TFLite needed)
   - Expected improvement: 3–5% precision gain on edge cases

2. **Hindi/regional language support**:
   - Add transliterated keyword maps for Hindi bank SMS
   - Consider using `intl` package for locale-aware parsing

3. **Credit card SMS templates**:
   - Add CC-specific regex patterns for major banks
   - Differentiate "card charged" from "card bill due" (not a transaction)

4. **Remote config for thresholds**:
   - Move `ScoringConfig` weights to Firebase Remote Config
   - A/B test threshold values (55 vs 60 vs 50) with real users
   - Auto-calibrate based on aggregated telemetry

5. **Format fingerprinting**:
   - Hash SMS templates (digits→#, names→X) to build a known-format
     database
   - New unknown formats get flagged for manual review
   - Gradually expands coverage without code changes

6. **Offline telemetry pipeline**:
   - Weekly batch upload of anonymized `TelemetryRecord` objects
   - BigQuery table for analysis
   - Dashboard showing: false positive rate, unknown format count,
     feature weight effectiveness
