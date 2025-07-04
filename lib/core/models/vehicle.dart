import 'package:cloud_firestore/cloud_firestore.dart';
// For @required, though not strictly necessary with null safety

enum VehicleType {
  abt,
  abtf,
  ur,
  asa,
  av,
}

enum VehicleStatus {
  available,
  inMaintenance,
  inUse,
  unavailable,
}

class Vehicle {
  final String? id;
  final String name;
  final VehicleType type;
  final String licensePlate;
  final String model;
  final int year;
  final VehicleStatus status;
  final String? observation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.licensePlate,
    required this.model,
    required this.year,
    required this.status,
    this.observation,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for saving to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'licensePlate': licensePlate,
      'model': model,
      'year': year,
      'status': status.toString().split('.').last,
      'observation': observation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create Vehicle from Map from Firestore
  factory Vehicle.fromFirestore(Map<String, dynamic> data, String id) {
    return Vehicle(
      id: id,
      name: data['name'] ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => VehicleType.ur, // Default or error handling
      ),
      licensePlate: data['licensePlate'] ?? '',
      model: data['model'] ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => VehicleStatus.unavailable, // Default or error handling
      ),
      observation: data['observation'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // copyWith method for creating copies with changes
  Vehicle copyWith({
    String? id,
    String? name,
    VehicleType? type,
    String? licensePlate,
    String? model,
    int? year,
    VehicleStatus? status,
    String? observation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      year: year ?? this.year,
      status: status ?? this.status,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, name: $name, type: $type, licensePlate: $licensePlate, model: $model, year: $year, status: $status)';
  }
}