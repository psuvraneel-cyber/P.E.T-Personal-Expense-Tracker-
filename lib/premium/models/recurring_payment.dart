class RecurringPayment {
  final String id;
  final String merchantName;
  final double amount;
  final String frequency; // daily, weekly, monthly, yearly
  final DateTime lastPaidAt;
  final DateTime nextDueAt;
  final String categoryId;
  final double confidence;
  final String source; // sms, notification, manual

  RecurringPayment({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.frequency,
    required this.lastPaidAt,
    required this.nextDueAt,
    required this.categoryId,
    this.confidence = 0.6,
    this.source = 'sms',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantName': merchantName,
      'amount': amount,
      'frequency': frequency,
      'lastPaidAt': lastPaidAt.toIso8601String(),
      'nextDueAt': nextDueAt.toIso8601String(),
      'categoryId': categoryId,
      'confidence': confidence,
      'source': source,
    };
  }

  factory RecurringPayment.fromMap(Map<String, dynamic> map) {
    return RecurringPayment(
      id: map['id'] as String,
      merchantName: map['merchantName'] as String,
      amount: (map['amount'] as num).toDouble(),
      frequency: map['frequency'] as String,
      lastPaidAt: DateTime.parse(map['lastPaidAt'] as String),
      nextDueAt: DateTime.parse(map['nextDueAt'] as String),
      categoryId: map['categoryId'] as String,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.6,
      source: map['source'] as String? ?? 'sms',
    );
  }

  RecurringPayment copyWith({
    String? id,
    String? merchantName,
    double? amount,
    String? frequency,
    DateTime? lastPaidAt,
    DateTime? nextDueAt,
    String? categoryId,
    double? confidence,
    String? source,
  }) {
    return RecurringPayment(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      categoryId: categoryId ?? this.categoryId,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
    );
  }
}
