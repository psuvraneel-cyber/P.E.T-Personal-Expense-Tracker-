class FamilyMember {
  final String id;
  final String name;
  final String role; // owner, member
  final double? monthlyLimit;

  FamilyMember({
    required this.id,
    required this.name,
    this.role = 'member',
    this.monthlyLimit,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role, 'monthlyLimit': monthlyLimit};
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String? ?? 'member',
      monthlyLimit: (map['monthlyLimit'] as num?)?.toDouble(),
    );
  }
}
