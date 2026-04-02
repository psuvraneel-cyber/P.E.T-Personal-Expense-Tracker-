import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/providers/transaction_provider.dart';
import 'package:pet/premium/widgets/premium_gate.dart';

// Indian IT section limits in INR
const _sectionLimits = {
  '80C': 150000.0,
  '80D': 25000.0,
  'HRA': 100000.0,
  'LTA': 20000.0,
  '80E': 150000.0,
};

const _sectionColors = {
  '80C': AppTheme.accentPurple,
  '80D': AppTheme.accentTeal,
  'HRA': Color(0xFFf59e0b),
  'LTA': Color(0xFF10b981),
  '80E': Color(0xFFef4444),
};

const _sectionDescriptions = {
  '80C': 'ELSS, PPF, LIC, PF, tuition fee',
  '80D': 'Health insurance premium',
  'HRA': 'House rent allowance',
  'LTA': 'Leave travel allowance',
  '80E': 'Education loan interest',
};

const _sectionEmojis = {
  '80C': '💼',
  '80D': '🏥',
  'HRA': '🏠',
  'LTA': '✈️',
  '80E': '🎓',
};

class TaxBucketsScreen extends StatefulWidget {
  const TaxBucketsScreen({super.key});

  @override
  State<TaxBucketsScreen> createState() => _TaxBucketsScreenState();
}

class _TaxBucketsScreenState extends State<TaxBucketsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withAlpha(isDark ? 40 : 25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF10b981),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Tax Buckets'),
          ],
        ),
        backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      ),
      body: PremiumGate(
        title: 'Tax Buckets',
        subtitle: 'Track deductible expenses by IT section.',
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            // Aggregate by tax category
            final totals = <String, double>{};
            for (final txn in provider.allTransactions) {
              if (txn.taxCategory == null) continue;
              totals[txn.taxCategory!] =
                  (totals[txn.taxCategory!] ?? 0) + txn.amount;
            }

            // Compute total deductions and estimated tax saved (30% flat)
            final totalDeductions = totals.values.fold(0.0, (s, v) => s + v);
            final estimatedSaved = totalDeductions * 0.30;
            final totalLimit = _sectionLimits.values.fold(0.0, (s, v) => s + v);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                _buildHeroBanner(
                  totalDeductions,
                  estimatedSaved,
                  totalLimit,
                  totals,
                  formatter,
                  isDark,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Deduction Buckets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (totals.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningYellow.withAlpha(
                            isDark ? 30 : 18,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tag transactions to populate',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.warningYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._sectionLimits.entries.toList().asMap().entries.map((outer) {
                  final i = outer.key;
                  final entry = outer.value;
                  final sectionId = entry.key;
                  final limit = entry.value;
                  final claimed = totals[sectionId] ?? 0.0;
                  final progress = limit > 0
                      ? (claimed / limit).clamp(0.0, 1.0)
                      : 0.0;
                  final color =
                      _sectionColors[sectionId] ?? AppTheme.accentPurple;

                  final delay = (i * 0.1).clamp(0.0, 0.5);
                  final animation = CurvedAnimation(
                    parent: _animCtrl,
                    curve: Interval(
                      delay,
                      (delay + 0.5).clamp(0, 1),
                      curve: Curves.easeOut,
                    ),
                  );

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, 20 * (1 - animation.value)),
                      child: Opacity(
                        opacity: animation.value.clamp(0, 1),
                        child: child,
                      ),
                    ),
                    child: _buildBucketCard(
                      context,
                      sectionId: sectionId,
                      name: sectionId,
                      description: _sectionDescriptions[sectionId] ?? sectionId,
                      claimed: claimed,
                      limit: limit,
                      progress: progress,
                      color: color,
                      emoji: _sectionEmojis[sectionId] ?? '📋',
                      formatter: formatter,
                      isDark: isDark,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner(
    double total,
    double saved,
    double totalLimit,
    Map<String, double> totals,
    NumberFormat formatter,
    bool isDark,
  ) {
    final overallProgress = totalLimit > 0
        ? (total / totalLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF7B3FE4), AppTheme.accentTeal],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withAlpha(70),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Claimed',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💰 ', style: TextStyle(fontSize: 12)),
                          Text(
                            'Est. tax saved: ${formatter.format(saved)} @ 30%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Mini donut chart
              AnimatedBuilder(
                animation: _animCtrl,
                builder: (_, __) => SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      sections: _sectionLimits.entries.map((e) {
                        final color =
                            _sectionColors[e.key] ?? AppTheme.accentPurple;
                        final claimed = totals[e.key] ?? 0;
                        final pct = e.value > 0 ? (claimed / e.value) : 0.0;
                        return _DonutSection(
                          color: color,
                          value: e.value,
                          filled: pct * _animCtrl.value,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: overallProgress * _animCtrl.value,
                    minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(30),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(overallProgress * 100).round()}% of total limit used',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Limit: ${formatter.format(totalLimit)}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketCard(
    BuildContext context, {
    required String sectionId,
    required String name,
    required String description,
    required double claimed,
    required double limit,
    required double progress,
    required Color color,
    required String emoji,
    required NumberFormat formatter,
    required bool isDark,
  }) {
    final remaining = (limit - claimed).clamp(0, double.infinity);
    final isMaxed = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isMaxed
              ? AppTheme.incomeGreen.withAlpha(isDark ? 55 : 35)
              : (isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.black.withAlpha(7)),
        ),
        boxShadow: isMaxed
            ? [
                BoxShadow(
                  color: AppTheme.incomeGreen.withAlpha(isDark ? 20 : 12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emoji icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(isDark ? 35 : 25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sectionId,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isMaxed ? AppTheme.incomeGreen : color,
                    ),
                  ),
                  if (isMaxed)
                    const Text(
                      'Maxed ✓',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.incomeGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress * _animCtrl.value,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.black.withAlpha(6),
                valueColor: AlwaysStoppedAnimation(
                  isMaxed ? AppTheme.incomeGreen : color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: formatter.format(claimed),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isMaxed ? AppTheme.incomeGreen : color,
                      ),
                    ),
                    TextSpan(
                      text: ' claimed',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${formatter.format(remaining)} remaining',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini donut chart painter ──────────────────────────────────────────────────

class _DonutSection {
  final Color color;
  final double value; // weight / size of slice
  final double filled; // 0..1 how much is filled

  const _DonutSection({
    required this.color,
    required this.value,
    required this.filled,
  });
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSection> sections;
  _DonutPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 12.0;
    const startAngle = -pi / 2;

    final total = sections.fold(0.0, (s, e) => s + e.value);
    if (total <= 0) return;

    double angle = startAngle;
    for (final section in sections) {
      final sweep = 2 * pi * (section.value / total);

      // Track (dim)
      final trackPaint = Paint()
        ..color = section.color.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        sweep,
        false,
        trackPaint,
      );

      // Filled portion
      if (section.filled > 0) {
        final fillPaint = Paint()
          ..color = section.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          angle,
          sweep * section.filled,
          false,
          fillPaint,
        );
      }

      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.sections != sections;
}
