class TaxCategory {
  final String id;
  final String name;
  final String description;

  TaxCategory({required this.id, required this.name, this.description = ''});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory TaxCategory.fromMap(Map<String, dynamic> map) {
    return TaxCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
    );
  }
}
