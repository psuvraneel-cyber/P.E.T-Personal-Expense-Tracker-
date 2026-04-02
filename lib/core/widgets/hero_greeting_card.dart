import 'package:flutter/material.dart';
import 'package:pet/core/theme/pet_colors.dart';
import 'package:pet/core/theme/typography.dart';
import 'package:pet/core/widgets/sync_status_chip.dart';
import 'package:intl/intl.dart';

/// A gradient hero card that replaces the plain text greeting.
///
/// Displays a contextual spending nudge based on today's actual data,
/// e.g. "You've spent ₹842 today — ₹158 left in your daily budget."
///
/// Embeds the existing [SyncStatusChip] for Firestore sync visibility.
class HeroGreetingCard extends StatelessWidget {
  final String greeting;
  final double todaySpent;
  final double dailyBudget;
  final String userName;

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  const HeroGreetingCard({
    super.key,
    required this.greeting,
    required this.todaySpent,
    required this.dailyBudget,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: PETColors.timeBasedGradient(isDark: isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PETColors.primary.withAlpha(isDark ? 40 : 60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              '$greeting, ${userName.isNotEmpty ? userName.split(' ').first : 'there'}!',
              style: AppTypography.heroGreeting(color: Colors.white),
            ),
            const SizedBox(height: 8),

            // Contextual nudge
            Text(
              _buildNudge(),
              style: AppTypography.bodyMedium(
                color: Colors.white.withAlpha(230),
              ),
            ),

            const SizedBox(height: 14),

            // Sync status
            const SyncStatusChip(),
          ],
        ),
      ),
    );
  }

  String _buildNudge() {
    if (dailyBudget <= 0) {
      if (todaySpent > 0) {
        return 'You\'ve spent ${_formatter.format(todaySpent)} today.';
      }
      return 'No spending tracked today. Start adding transactions!';
    }

    final remaining = dailyBudget - todaySpent;
    if (todaySpent == 0) {
      return 'Daily budget: ${_formatter.format(dailyBudget)}. No spending yet today! 🎯';
    }
    if (remaining > 0) {
      return 'You\'ve spent ${_formatter.format(todaySpent)} today — '
          '${_formatter.format(remaining)} left in your daily budget. Looking good! ✅';
    }
    return 'You\'ve exceeded today\'s daily budget by '
        '${_formatter.format(-remaining)}. Consider pausing non-essentials. 💡';
  }
}
