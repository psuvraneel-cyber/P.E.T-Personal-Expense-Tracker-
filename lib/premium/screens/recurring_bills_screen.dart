import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/premium/models/recurring_payment.dart';
import 'package:pet/premium/providers/recurring_provider.dart';
import 'package:pet/premium/widgets/premium_gate.dart';

// Icon map — guesses icon from merchant name keywords
IconData _billIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('netflix') ||
      n.contains('prime') ||
      n.contains('hotstar') ||
      n.contains('zee') ||
      n.contains('sony')) {
    return Icons.movie_rounded;
  } else if (n.contains('spotify') ||
      n.contains('gaana') ||
      n.contains('music') ||
      n.contains('jiosaavn')) {
    return Icons.music_note_rounded;
  } else if (n.contains('gym') || n.contains('fitness') || n.contains('cult')) {
    return Icons.fitness_center_rounded;
  } else if (n.contains('electricity') ||
      n.contains('bescom') ||
      n.contains('power')) {
    return Icons.electrical_services_rounded;
  } else if (n.contains('rent') ||
      n.contains('house') ||
      n.contains('maintenance')) {
    return Icons.home_rounded;
  } else if (n.contains('insurance') || n.contains('lic')) {
    return Icons.health_and_safety_rounded;
  } else if (n.contains('internet') ||
      n.contains('broadband') ||
      n.contains('wifi') ||
      n.contains('act ') ||
      n.contains('jio')) {
    return Icons.wifi_rounded;
  } else if (n.contains('mobile') ||
      n.contains('phone') ||
      n.contains('airtel') ||
      n.contains('vodafone') ||
      n.contains('bsnl')) {
    return Icons.phone_android_rounded;
  } else if (n.contains('emi') || n.contains('loan') || n.contains('bank')) {
    return Icons.account_balance_rounded;
  } else if (n.contains('gas') || n.contains('lpg')) {
    return Icons.local_fire_department_rounded;
  } else if (n.contains('water')) {
    return Icons.water_drop_rounded;
  } else if (n.contains('cloud') ||
      n.contains('drive') ||
      n.contains('dropbox')) {
    return Icons.cloud_rounded;
  }
  return Icons.receipt_long_rounded;
}

Color _billColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('netflix')) return const Color(0xFFe50914);
  if (n.contains('spotify')) return const Color(0xFF1DB954);
  if (n.contains('prime')) return const Color(0xFF00A8E1);
  if (n.contains('hotstar') || n.contains('disney')) {
    return const Color(0xFF1C6EDC);
  }
  if (n.contains('gym') || n.contains('fitness') || n.contains('cult')) {
    return const Color(0xFFf59e0b);
  }
  if (n.contains('electricity') || n.contains('power')) {
    return const Color(0xFFf59e0b);
  }
  if (n.contains('insurance')) return const Color(0xFF10b981);
  return AppTheme.accentTeal;
}

class RecurringBillsScreen extends StatefulWidget {
  const RecurringBillsScreen({super.key});

  @override
  State<RecurringBillsScreen> createState() => _RecurringBillsScreenState();
}

class _RecurringBillsScreenState extends State<RecurringBillsScreen> {
  final _currFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final _dateFmt = DateFormat('dd MMM');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurringProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      appBar: AppBar(
        title: const Text('Bills & Subscriptions'),
        backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
        actions: [
          IconButton(
            onPressed: () => _showAddBill(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PremiumGate(
        title: 'Bills & Subscriptions',
        subtitle: 'Track upcoming payments and recurring spending.',
        child: Consumer<RecurringProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.recurring.isEmpty) {
              return _buildEmpty(isDark);
            }

            final totalMonthly = provider.recurring
                .where((r) => r.frequency == 'monthly')
                .fold(0.0, (s, r) => s + r.amount);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              children: [
                const SizedBox(height: 8),
                _buildSummaryBanner(
                  context,
                  totalMonthly,
                  provider.recurring,
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildWeekStrip(provider.recurring, isDark),
                const SizedBox(height: 16),
                Text(
                  'All Bills',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...provider.recurring.map(
                  (r) => _buildBillCard(context, r, provider, isDark),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryBanner(
    BuildContext context,
    double totalMonthly,
    List<RecurringPayment> bills,
    bool isDark,
  ) {
    final now = DateTime.now();
    final weekBills = bills
        .where(
          (b) =>
              b.nextDueAt.isAfter(now) &&
              b.nextDueAt.difference(now).inDays <= 7,
        )
        .toList();
    final weekTotal = weekBills.fold(0.0, (s, b) => s + b.amount);
    final totalAnnual = bills.fold(0.0, (s, b) {
      return s +
          switch (b.frequency) {
            'weekly' => b.amount * 52,
            'yearly' => b.amount,
            _ => b.amount * 12,
          };
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentTeal.withAlpha(isDark ? 60 : 40),
            AppTheme.accentPurple.withAlpha(isDark ? 40 : 25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentTeal.withAlpha(isDark ? 50 : 35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Recurring',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currFmt.format(totalMonthly),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withAlpha(25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due this week',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekBills.isEmpty
                          ? 'None due'
                          : _currFmt.format(weekTotal),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: weekBills.isEmpty
                            ? AppTheme.incomeGreen
                            : AppTheme.warningYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  'Annual commitment: ${_currFmt.format(totalAnnual)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(List<RecurringPayment> bills, bool isDark) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 7 Days',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: days.map((day) {
            final dayBills = bills
                .where(
                  (b) =>
                      b.nextDueAt.year == day.year &&
                      b.nextDueAt.month == day.month &&
                      b.nextDueAt.day == day.day,
                )
                .toList();
            final hasBill = dayBills.isNotEmpty;
            final isToday =
                day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;

            return Expanded(
              child: Column(
                children: [
                  Text(
                    dayLabels[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? AppTheme.accentPurple
                          : AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasBill
                          ? AppTheme.warningYellow.withAlpha(isDark ? 40 : 28)
                          : (isDark
                                ? Colors.white.withAlpha(8)
                                : Colors.black.withAlpha(5)),
                      shape: BoxShape.circle,
                      border: hasBill
                          ? Border.all(color: AppTheme.warningYellow, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: hasBill
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: hasBill
                              ? AppTheme.warningYellow
                              : (isToday
                                    ? AppTheme.accentPurple
                                    : AppTheme.textTertiary),
                        ),
                      ),
                    ),
                  ),
                  if (hasBill) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.warningYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBillCard(
    BuildContext context,
    RecurringPayment bill,
    RecurringProvider provider,
    bool isDark,
  ) {
    final daysUntil = bill.nextDueAt.difference(DateTime.now()).inDays;
    final isOverdue = daysUntil < 0;
    final isDueSoon = !isOverdue && daysUntil <= 3;
    final statusColor = isOverdue
        ? AppTheme.expenseRed
        : isDueSoon
        ? AppTheme.warningYellow
        : AppTheme.incomeGreen;

    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.accentTeal.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.snooze_rounded, color: AppTheme.accentTeal),
            Text(
              'Snooze',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        await provider.snoozeBill(bill.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text('${bill.merchantName} snoozed by one cycle'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return false; // don't actually remove the item
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.black.withAlpha(7),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _billColor(
                  bill.merchantName,
                ).withAlpha(isDark ? 35 : 22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _billIcon(bill.merchantName),
                color: _billColor(bill.merchantName),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.merchantName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withAlpha(
                            isDark ? 25 : 18,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bill.frequency,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due ${_dateFmt.format(bill.nextDueAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currFmt.format(bill.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.expenseRed,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOverdue
                        ? 'Overdue'
                        : isDueSoon
                        ? '$daysUntil day${daysUntil == 1 ? '' : 's'}'
                        : 'In $daysUntil days',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(isDark ? 40 : 28),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.repeat_rounded,
                size: 40,
                color: AppTheme.accentTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Bills Tracked',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add subscriptions manually, or bills will be\nauto-detected from your SMS transactions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBill(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Bill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBill(BuildContext context) async {
    final provider = context.read<RecurringProvider>();
    final merchantCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String frequency = 'monthly';
    DateTime nextDue = DateTime.now().add(const Duration(days: 30));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Recurring Bill',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: merchantCtrl,
                decoration: const InputDecoration(
                  labelText: 'Merchant / Subscription name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(
                  labelText: 'Billing frequency',
                ),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (v) => setS(() => frequency = v ?? 'monthly'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = merchantCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || amount <= 0) return;
                    provider.addManual(
                      merchantName: name,
                      amount: amount,
                      frequency: frequency,
                      nextDueAt: nextDue,
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
