import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pet/providers/transaction_provider.dart';
import 'package:pet/core/theme/app_theme.dart';

/// A small chip shown in the app bar that reflects the current Firestore
/// sync state: syncing (spinner), synced (green dot + time), or error (red).
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<TransactionProvider, SyncStatus>(
      (p) => p.syncStatus,
    );
    final lastSyncAt = context.select<TransactionProvider, DateTime?>(
      (p) => p.lastSyncAt,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildChip(context, status, lastSyncAt),
    );
  }

  Widget _buildChip(
    BuildContext context,
    SyncStatus status,
    DateTime? lastSyncAt,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case SyncStatus.syncing:
        return _Chip(
          key: const ValueKey('syncing'),
          icon: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.accentTeal : AppTheme.accentTeal,
              ),
            ),
          ),
          label: 'Syncing…',
          color: AppTheme.accentTeal,
          isDark: isDark,
        );

      case SyncStatus.synced:
        final timeStr = lastSyncAt != null
            ? DateFormat('hh:mm a').format(lastSyncAt)
            : '';
        return _Chip(
          key: const ValueKey('synced'),
          icon: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.incomeGreen,
              shape: BoxShape.circle,
            ),
          ),
          label: 'Synced${timeStr.isNotEmpty ? ' · $timeStr' : ''}',
          color: AppTheme.incomeGreen,
          isDark: isDark,
        );

      case SyncStatus.error:
        return _Chip(
          key: const ValueKey('error'),
          icon: const Icon(
            Icons.cloud_off,
            size: 10,
            color: AppTheme.expenseRed,
          ),
          label: 'Sync error',
          color: AppTheme.expenseRed,
          isDark: isDark,
        );

      case SyncStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));
    }
  }
}

class _Chip extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final bool isDark;

  const _Chip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
