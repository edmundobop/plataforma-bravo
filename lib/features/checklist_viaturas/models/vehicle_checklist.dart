import 'dart:typed_data';
import 'checklist_category.dart';

class VehicleChecklist {
  final String? id; // ID do documento no Firebase
  final String vehicleType;
  final String vehicleId;
  final String vehiclePlate;
  final String responsibleName;
  final String responsibleRank;
  final String responsibleRegistration;
  final DateTime date;
  final List<ChecklistCategory> categories;
  final String? generalObservations;
  final Uint8List? signature;
  final String? signatureUrl; // URL da assinatura no Firebase Storage
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleChecklist({
    this.id,
    required this.vehicleType,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.responsibleName,
    required this.responsibleRank,
    required this.responsibleRegistration,
    required this.date,
    required this.categories,
    this.generalObservations,
    this.signature,
    this.signatureUrl,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  // Getters calculados
  int get totalItems => categories.fold(0, (sum, category) => sum + category.items.length);
  
  int get completedItems => categories.fold(0, (sum, category) => sum + category.completedCount);
  
  double get overallCompletionPercentage {
    if (totalItems == 0) return 0.0;
    return (completedItems / totalItems) * 100;
  }

  // Método copyWith
  VehicleChecklist copyWith({
    String? id,
    String? vehicleType,
    String? vehicleId,
    String? vehiclePlate,
    String? responsibleName,
    String? responsibleRank,
    String? responsibleRegistration,
    DateTime? date,
    List<ChecklistCategory>? categories,
    String? generalObservations,
    Uint8List? signature,
    String? signatureUrl,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleChecklist(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      responsibleName: responsibleName ?? this.responsibleName,
      responsibleRank: responsibleRank ?? this.responsibleRank,
      responsibleRegistration: responsibleRegistration ?? this.responsibleRegistration,
      date: date ?? this.date,
      categories: categories ?? this.categories,
      generalObservations: generalObservations ?? this.generalObservations,
      signature: signature ?? this.signature,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Serialização para Firebase
  Map<String, dynamic> toMap() {
    return {
      'vehicleType': vehicleType,
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
      'responsibleName': responsibleName,
      'responsibleRank': responsibleRank,
      'responsibleRegistration': responsibleRegistration,
      'date': date.toIso8601String(),
      'categories': categories.map((category) => category.toMap()).toList(),
      'generalObservations': generalObservations,
      'signatureUrl': signatureUrl,
      'isCompleted': isCompleted,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'completionPercentage': overallCompletionPercentage,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Deserialização do Firebase
  factory VehicleChecklist.fromMap(Map<String, dynamic> map, String documentId) {
    return VehicleChecklist(
      id: documentId,
      vehicleType: map['vehicleType'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      responsibleName: map['responsibleName'] ?? '',
      responsibleRank: map['responsibleRank'] ?? '',
      responsibleRegistration: map['responsibleRegistration'] ?? '',
      date: _parseDateTime(map['date']) ?? DateTime.now(),
      categories: (map['categories'] as List<dynamic>?)
          ?.map((categoryMap) => ChecklistCategory.fromMap(categoryMap))
          .toList() ?? [],
      generalObservations: map['generalObservations'],
      signatureUrl: map['signatureUrl'],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // Método auxiliar para converter Timestamp ou String para DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    // Se for um Timestamp do Firebase
    if (value.runtimeType.toString().contains('Timestamp')) {
      return (value as dynamic).toDate();
    }

    // Se for uma String
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Erro ao converter data: $value - $e');
        return null;
      }
    }

    // Se for um DateTime
    if (value is DateTime) {
      return value;
    }

    print('Tipo de data não reconhecido: ${value.runtimeType} - $value');
    return null;
  }

  // Método para JSON (útil para debug)
  Map<String, dynamic> toJson() => toMap();

  factory VehicleChecklist.fromJson(Map<String, dynamic> json, String documentId) {
    return VehicleChecklist.fromMap(json, documentId);
  }

  @override
  String toString() {
    return 'VehicleChecklist(id: $id, vehicleType: $vehicleType, vehicleId: $vehicleId, '
           'isCompleted: $isCompleted, completionPercentage: ${overallCompletionPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleChecklist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}