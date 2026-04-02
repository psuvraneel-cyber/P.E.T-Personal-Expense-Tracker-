import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/data/models/sms_transaction.dart';
import 'package:pet/providers/sms_transaction_provider.dart';

/// Screen showing uncertain/low-confidence transactions for user review.
/// Users can accept (as debit or credit) or reject each transaction.
class PendingReviewScreen extends StatelessWidget {
  const PendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
        title: const Text('Pending Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SmsTransactionProvider>(
        builder: (context, provider, _) {
          final uncertain = provider.uncertainTransactions;

          if (uncertain.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: AppTheme.incomeGreen.withAlpha(150),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'All Clear!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No uncertain transactions to review.\n'
                      'Transactions with low confidence will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(isDark ? 25 : 18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.amber.withAlpha(isDark ? 40 : 30),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${uncertain.length} possible transaction${uncertain.length > 1 ? 's' : ''} '
                        'need your review. Swipe right to accept, left to reject.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: uncertain.length,
                  itemBuilder: (context, index) {
                    final txn = uncertain[index];
                    return _UncertainTransactionCard(
                      txn: txn,
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UncertainTransactionCard extends StatelessWidget {
  final SmsTransaction txn;
  final bool isDark;
  final NumberFormat currencyFormat;

  const _UncertainTransactionCard({
    required this.txn,
    required this.isDark,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = txn.transactionType == 'debit';
    final amountColor = isDebit ? AppTheme.expenseRed : AppTheme.incomeGreen;
    final dateStr = txn.timestampIsApproximate
        ? DateFormat('dd MMM yyyy').format(txn.timestamp)
        : DateFormat('dd MMM, hh:mm a').format(txn.timestamp);
    final confidencePercent = (txn.confidence * 100).toStringAsFixed(0);

    return Dismissible(
      key: Key('uncertain_${txn.id}'),
      // Swipe right to accept
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.incomeGreen.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_rounded, color: AppTheme.incomeGreen),
            SizedBox(width: 6),
            Text(
              'Accept',
              style: TextStyle(
                color: AppTheme.incomeGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // Swipe left to reject
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.expenseRed.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Reject',
              style: TextStyle(
                color: AppTheme.expenseRed,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.close_rounded, color: AppTheme.expenseRed),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final provider = Provider.of<SmsTransactionProvider>(
          context,
          listen: false,
        );
        if (direction == DismissDirection.startToEnd) {
          // Accept — ask user to confirm type
          final type = await _showTypeConfirmDialog(context);
          if (type == null) return false;
          await provider.acceptUncertainTransaction(txn.id, overrideType: type);
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Accepted as $type'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.incomeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return false; // Already handled
        } else {
          // Reject
          await provider.rejectUncertainTransaction(txn.id);
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Marked as not a transaction'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.textTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return false; // Already handled
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withAlpha(isDark ? 30 : 20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: merchant + amount
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(isDark ? 25 : 18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.merchantName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${txn.bankName}  •  $dateStr',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textTertiary
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(txn.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(isDark ? 20 : 14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$confidencePercent% sure',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept as Debit',
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.expenseRed,
                    isDark: isDark,
                    onTap: () {
                      Provider.of<SmsTransactionProvider>(
                        context,
                        listen: false,
                      ).acceptUncertainTransaction(
                        txn.id,
                        overrideType: 'debit',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionButton(
                    label: 'Accept as Credit',
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.incomeGreen,
                    isDark: isDark,
                    onTap: () {
                      Provider.of<SmsTransactionProvider>(
                        context,
                        listen: false,
                      ).acceptUncertainTransaction(
                        txn.id,
                        overrideType: 'credit',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  label: 'Not a txn',
                  icon: Icons.close_rounded,
                  color: AppTheme.textTertiary,
                  isDark: isDark,
                  onTap: () {
                    Provider.of<SmsTransactionProvider>(
                      context,
                      listen: false,
                    ).rejectUncertainTransaction(txn.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showTypeConfirmDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transaction Type'),
        content: const Text(
          'Is this a debit (money out) or credit (money in)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'debit'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseRed),
            child: const Text('Debit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'credit'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.incomeGreen),
            child: const Text('Credit'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 18 : 12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(isDark ? 30 : 20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
