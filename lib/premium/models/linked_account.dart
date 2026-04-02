class LinkedAccount {
  final String id;
  final String provider; // sms, notification, mock
  final String accountName;
  final String accountType; // bank, wallet, card
  final DateTime? lastSyncedAt;
  final String status; // active, paused

  LinkedAccount({
    required this.id,
    required this.provider,
    required this.accountName,
    required this.accountType,
    this.lastSyncedAt,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider': provider,
      'accountName': accountName,
      'accountType': accountType,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'status': status,
    };
  }

  factory LinkedAccount.fromMap(Map<String, dynamic> map) {
    return LinkedAccount(
      id: map['id'] as String,
      provider: map['provider'] as String,
      accountName: map['accountName'] as String,
      accountType: map['accountType'] as String,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
      status: map['status'] as String? ?? 'active',
    );
  }
}
