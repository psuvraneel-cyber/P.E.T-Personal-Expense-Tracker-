import 'package:pet/data/models/enums.dart';
import 'package:pet/data/models/transaction.dart';
import 'package:pet/premium/models/cashflow_forecast.dart';

class CashflowForecastService {
  CashflowForecastService._();

  static CashflowForecast forecast(
    List<TransactionRecord> transactions, {
    int days = 30,
  }) {
    final now = DateTime.now();
    double balance = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else if (t.type == TransactionType.expense) {
        balance -= t.amount;
      }
    }

    final dailyPoints = <CashflowPoint>[];
    final avgDailyExpense = _avgDailyExpense(transactions);

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      balance -= avgDailyExpense;
      dailyPoints.add(CashflowPoint(date: date, balance: balance));
    }

    final safeToSpend = avgDailyExpense * 0.9;

    return CashflowForecast(
      startingBalance: dailyPoints.first.balance + avgDailyExpense,
      projectedEndingBalance: dailyPoints.isNotEmpty
          ? dailyPoints.last.balance
          : balance,
      safeToSpend: safeToSpend,
      dailyPoints: dailyPoints,
    );
  }

  static double _avgDailyExpense(List<TransactionRecord> transactions) {
    if (transactions.isEmpty) return 0;
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) return 0;
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    return total / 30.0;
  }
}
