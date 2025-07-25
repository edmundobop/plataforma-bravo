import 'package:cloud_firestore/cloud_firestore.dart';

class FireUnit {
  final String id;
  final String name;
  final String code; // Código da unidade (ex: 1º GBM, 2º GBM)
  final String address;
  final String city;
  final String state;
  final String phone;
  final String email;
  final String commanderName;
  final String commanderRank;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata; // Dados adicionais específicos da unidade

  const FireUnit({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    required this.email,
    required this.commanderName,
    required this.commanderRank,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Converter para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
      'commanderName': commanderName,
      'commanderRank': commanderRank,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  // Criar instância a partir do Firestore
  factory FireUnit.fromMap(Map<String, dynamic> map) {
    return FireUnit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? 'GO',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      commanderName: map['commanderName'] ?? '',
      commanderRank: map['commanderRank'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      metadata: map['metadata'],
    );
  }

  // Criar instância a partir do DocumentSnapshot
  factory FireUnit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FireUnit.fromMap({...data, 'id': doc.id});
  }

  // Método copyWith para atualizações
  FireUnit copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? state,
    String? phone,
    String? email,
    String? commanderName,
    String? commanderRank,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FireUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      commanderName: commanderName ?? this.commanderName,
      commanderRank: commanderRank ?? this.commanderRank,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'FireUnit(id: $id, name: $name, code: $code, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FireUnit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum para tipos de unidades
enum UnitType {
  gbm, // Grupamento de Bombeiros Militar
  cbm, // Comando de Bombeiros Militar
  subgrupamento,
  destacamento,
  posto,
}

extension UnitTypeExtension on UnitType {
  String get displayName {
    switch (this) {
      case UnitType.gbm:
        return 'Grupamento de Bombeiros Militar';
      case UnitType.cbm:
        return 'Comando de Bombeiros Militar';
      case UnitType.subgrupamento:
        return 'Subgrupamento';
      case UnitType.destacamento:
        return 'Destacamento';
      case UnitType.posto:
        return 'Posto';
    }
  }

  String get abbreviation {
    switch (this) {
      case UnitType.gbm:
        return 'GBM';
      case UnitType.cbm:
        return 'CBM';
      case UnitType.subgrupamento:
        return 'SUBGBM';
      case UnitType.destacamento:
        return 'DEST';
      case UnitType.posto:
        return 'POSTO';
    }
  }
}