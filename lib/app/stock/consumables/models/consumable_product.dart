class ConsumableProduct {
  final String id;
  final String name;
  final String description;
  final String category; // Alimentício, Limpeza, APH, etc.
  final String measurementUnit; // Unidade, Kg, L, etc.
  final double minimumStock;
  final double currentStock;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConsumableProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.measurementUnit,
    required this.minimumStock,
    required this.currentStock,
    required this.createdAt,
    this.updatedAt,
  });

  ConsumableProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? measurementUnit,
    double? minimumStock,
    double? currentStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConsumableProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      minimumStock: minimumStock ?? this.minimumStock,
      currentStock: currentStock ?? this.currentStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'measurementUnit': measurementUnit,
      'minimumStock': minimumStock,
      'currentStock': currentStock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ConsumableProduct.fromMap(Map<String, dynamic> map) {
    return ConsumableProduct(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      measurementUnit: map['measurementUnit'],
      minimumStock: map['minimumStock'],
      currentStock: map['currentStock'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}