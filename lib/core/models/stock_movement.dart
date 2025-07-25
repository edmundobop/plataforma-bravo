import 'package:cloud_firestore/cloud_firestore.dart';

enum MovementType { entry, exit }

class StockMovement {
  final String? id;
  final String productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final String reason;
  final String? observation;
  final DateTime createdAt;
  final String userId;
  final String unitId; // Campo para isolamento multi-tenant

  StockMovement({
    this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.reason,
    this.observation,
    required this.createdAt,
    required this.userId,
    required this.unitId,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'observation': observation,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'unitId': unitId,
    };
  }

  // Método toMap para compatibilidade
  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // Criar StockMovement a partir de Map do Firestore
  factory StockMovement.fromFirestore(Map<String, dynamic> data, String id) {
    return StockMovement(
      id: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      type: data['type'] == 'entry' ? MovementType.entry : MovementType.exit,
      quantity: data['quantity'] ?? 0,
      reason: data['reason'] ?? '',
      observation: data['observation'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      unitId: data['unitId'] ?? '',
    );
  }

  // Método copyWith para criar cópias com alterações
  StockMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    MovementType? type,
    int? quantity,
    String? reason,
    String? observation,
    DateTime? createdAt,
    String? userId,
    String? unitId,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      unitId: unitId ?? this.unitId,
    );
  }

  // Método toString para debug
  @override
  String toString() {
    return 'StockMovement(id: $id, productName: $productName, type: $type, quantity: $quantity)';
  }

  // Métodos de comparação
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockMovement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Verificar se é entrada
  bool get isEntry => type == MovementType.entry;

  // Verificar se é saída
  bool get isExit => type == MovementType.exit;

  // Obter descrição do tipo
  String get typeDescription {
    switch (type) {
      case MovementType.entry:
        return 'Entrada';
      case MovementType.exit:
        return 'Saída';
    }
  }

  // Obter ícone do tipo
  String get typeIcon {
    switch (type) {
      case MovementType.entry:
        return '↗️';
      case MovementType.exit:
        return '↘️';
    }
  }

  // Formatar data
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Verificar se a movimentação é recente (últimas 24h)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  // Obter descrição completa
  String get fullDescription {
    final buffer = StringBuffer();
    buffer.write('$typeDescription de $quantity unidades');
    if (observation != null && observation!.isNotEmpty) {
      buffer.write(' - $observation');
    }
    return buffer.toString();
  }
}