class BudgetAlert {
  final String id;
  final String type; // budget, anomaly, bill, system
  final String title;
  final String message;
  final String? categoryId;
  final DateTime createdAt;
  final bool isRead;
  final String? alertKey;

  BudgetAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.categoryId,
    this.isRead = false,
    this.alertKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'alertKey': alertKey,
    };
  }

  factory BudgetAlert.fromMap(Map<String, dynamic> map) {
    return BudgetAlert(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      categoryId: map['categoryId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isRead: (map['isRead'] as int? ?? 0) == 1,
      alertKey: map['alertKey'] as String?,
    );
  }

  BudgetAlert copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? categoryId,
    DateTime? createdAt,
    bool? isRead,
    String? alertKey,
  }) {
    return BudgetAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      alertKey: alertKey ?? this.alertKey,
    );
  }
}
