import 'package:flutter/material.dart';
import 'package:pet/data/models/sms_transaction.dart';
import 'package:pet/premium/models/recurring_payment.dart';
import 'package:pet/premium/repositories/recurring_payment_repository.dart';
import 'package:pet/premium/services/recurring_detection_service.dart';
import 'package:pet/premium/models/budget_alert.dart';
import 'package:pet/premium/repositories/alert_repository.dart';
import 'package:pet/premium/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class RecurringProvider extends ChangeNotifier {
  final RecurringPaymentRepository _repository = RecurringPaymentRepository();
  final AlertRepository _alertRepository = AlertRepository();
  final Uuid _uuid = const Uuid();

  List<RecurringPayment> _recurring = [];
  bool _isLoading = false;

  List<RecurringPayment> get recurring => _recurring;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _recurring = await _repository.getAll();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a manually entered recurring payment.
  Future<void> addManual({
    required String merchantName,
    required double amount,
    required String frequency,
    required DateTime nextDueAt,
    String categoryId = 'other',
  }) async {
    final payment = RecurringPayment(
      id: _uuid.v4(),
      merchantName: merchantName,
      amount: amount,
      frequency: frequency,
      lastPaidAt: DateTime.now(),
      nextDueAt: nextDueAt,
      categoryId: categoryId,
      confidence: 1.0,
      source: 'manual',
    );
    await _repository.upsert(payment);
    _recurring.insert(0, payment);
    notifyListeners();
  }

  /// Push the next due date by one billing cycle (snooze).
  Future<void> snoozeBill(String id) async {
    final index = _recurring.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final bill = _recurring[index];
    Duration cycle;
    switch (bill.frequency) {
      case 'weekly':
        cycle = const Duration(days: 7);
        break;
      case 'yearly':
        cycle = const Duration(days: 365);
        break;
      default:
        cycle = const Duration(days: 30);
    }
    final updated = bill.copyWith(nextDueAt: bill.nextDueAt.add(cycle));
    _recurring[index] = updated;
    await _repository.upsert(updated);
    notifyListeners();
  }

  Future<void> deleteBill(String id) async {
    await _repository.delete(id);
    _recurring.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> refreshFromSms(List<SmsTransaction> sms) async {
    _isLoading = true;
    notifyListeners();

    final detected = RecurringDetectionService.detect(sms);
    await _repository.clearAll();
    for (final payment in detected) {
      await _repository.upsert(payment);
    }
    _recurring = detected;

    await _notifyUpcomingBills(detected);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _notifyUpcomingBills(List<RecurringPayment> recurring) async {
    final now = DateTime.now();
    for (final item in recurring) {
      final days = item.nextDueAt.difference(now).inDays;
      if (days < 0 || days > 3) continue;

      final alertKey =
          'bill_${item.merchantName}_${item.nextDueAt.toIso8601String()}';
      final exists = await _alertRepository.existsByKey(alertKey);
      if (exists) continue;

      final alert = BudgetAlert(
        id: _uuid.v4(),
        type: 'bill',
        title: 'Upcoming bill due',
        message:
            '${item.merchantName} due in $days day${days == 1 ? '' : 's'}.',
        createdAt: DateTime.now(),
        alertKey: alertKey,
      );
      await _alertRepository.insert(alert);

      await NotificationService.showInstant(
        id: alert.createdAt.millisecondsSinceEpoch ~/ 1000,
        title: alert.title,
        body: alert.message,
      );
    }
  }
}
