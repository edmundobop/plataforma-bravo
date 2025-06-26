import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final String category;
  final String unit;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'unit': unit,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Criar Product a partir de Map do Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      unit: data['unit'] ?? '',
      currentStock: data['currentStock'] ?? 0,
      minStock: data['minStock'] ?? 0,
      maxStock: data['maxStock'] ?? 0,
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Método copyWith para criar cópias com alterações
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? unit,
    int? currentStock,
    int? minStock,
    int? maxStock,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método toString para debug
  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, currentStock: $currentStock)';
  }

  // Métodos de comparação
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Verificar se o estoque está baixo
  bool get isLowStock => currentStock <= minStock;

  // Verificar se o estoque está crítico
  bool get isCriticalStock => currentStock < (minStock * 0.5);

  // Obter status do estoque
  String get stockStatus {
    if (isCriticalStock) return 'Crítico';
    if (isLowStock) return 'Baixo';
    return 'Normal';
  }

  // Obter porcentagem do estoque
  double get stockPercentage {
    if (maxStock == 0) return 0;
    return (currentStock / maxStock) * 100;
  }

  // Verificar se pode fazer saída
  bool canExit(int quantity) => currentStock >= quantity;

  // Calcular quantidade sugerida para compra
  int get suggestedPurchaseQuantity {
    if (currentStock >= minStock) return 0;
    return maxStock - currentStock;
  }
}