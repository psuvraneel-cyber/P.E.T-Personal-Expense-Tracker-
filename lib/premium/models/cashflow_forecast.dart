class CashflowForecast {
  final double startingBalance;
  final double projectedEndingBalance;
  final double safeToSpend;
  final List<CashflowPoint> dailyPoints;

  CashflowForecast({
    required this.startingBalance,
    required this.projectedEndingBalance,
    required this.safeToSpend,
    required this.dailyPoints,
  });
}

class CashflowPoint {
  final DateTime date;
  final double balance;

  CashflowPoint({required this.date, required this.balance});
}
