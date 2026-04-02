import 'package:flutter/material.dart';
import 'package:pet/data/models/enums.dart';
import 'package:pet/data/models/transaction.dart';

/// Analyses past transaction data to suggest budgets for categories.
///
/// When a user creates a category without a budget, this service
/// calculates a suggested amount based on the last 3 months of
/// spending in that category.
class BudgetSuggestionService {
  BudgetSuggestionService._();
  static final BudgetSuggestionService instance = BudgetSuggestionService._();

  /// Suggest a monthly budget for the given category based on
  /// the last [monthsBack] months of transactions.
  ///
  /// Returns `null` if there are fewer than 3 transactions in the
  /// category (insufficient data for a meaningful suggestion).
  BudgetSuggestion? suggestBudget({
    required String categoryId,
    required List<TransactionRecord> allTransactions,
    int monthsBack = 3,
  }) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - monthsBack, 1);

    // Filter to expense transactions in this category within the window
    final relevant = allTransactions.where((t) {
      return t.categoryId == categoryId &&
          t.type == TransactionType.expense &&
          t.date.isAfter(cutoff);
    }).toList();

    if (relevant.length < 3) return null;

    final totalSpent = relevant.fold<double>(0, (sum, t) => sum + t.amount);
    final months = _countDistinctMonths(relevant);
    if (months == 0) return null;

    final avgMonthly = totalSpent / months;

    // Round up to nearest ₹100 for a cleaner number
    final suggested = (avgMonthly / 100).ceil() * 100.0;

    return BudgetSuggestion(
      categoryId: categoryId,
      suggestedAmount: suggested,
      averageMonthly: avgMonthly,
      basedOnMonths: months,
      transactionCount: relevant.length,
    );
  }

  int _countDistinctMonths(List<TransactionRecord> transactions) {
    final months = <String>{};
    for (final t in transactions) {
      months.add('${t.date.year}-${t.date.month}');
    }
    return months.length;
  }
}

/// Result of a budget suggestion analysis.
@immutable
class BudgetSuggestion {
  final String categoryId;
  final double suggestedAmount;
  final double averageMonthly;
  final int basedOnMonths;
  final int transactionCount;

  const BudgetSuggestion({
    required this.categoryId,
    required this.suggestedAmount,
    required this.averageMonthly,
    required this.basedOnMonths,
    required this.transactionCount,
  });
}
