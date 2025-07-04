import 'package:cloud_firestore/cloud_firestore.dart';

enum ChecklistItemStatus {
  ok,
  notOk,
  na, // Not Applicable
}

enum ChecklistStatus {
  completed,
  pending,
  failed,
}

class ChecklistItem {
  final String description;
  ChecklistItemStatus status;
  String? observation;

  ChecklistItem({
    required this.description,
    this.status = ChecklistItemStatus.ok,
    this.observation,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'status': status.toString().split('.').last,
      'observation': observation,
    };
  }

  factory ChecklistItem.fromFirestore(Map<String, dynamic> data) {
    return ChecklistItem(
      description: data['description'] ?? '',
      status: ChecklistItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ChecklistItemStatus.ok,
      ),
      observation: data['observation'],
    );
  }
}

class Checklist {
  final String? id;
  final String vehicleId;
  final String userId;
  final DateTime checklistDate;
  final ChecklistStatus status;
  final String? generalObservations;
  final List<ChecklistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Checklist({
    this.id,
    required this.vehicleId,
    required this.userId,
    required this.checklistDate,
    required this.status,
    this.generalObservations,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'checklistDate': Timestamp.fromDate(checklistDate),
      'status': status.toString().split('.').last,
      'generalObservations': generalObservations,
      'items': items.map((item) => item.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Checklist.fromFirestore(Map<String, dynamic> data, String id) {
    return Checklist(
      id: id,
      vehicleId: data['vehicleId'] ?? '',
      userId: data['userId'] ?? '',
      checklistDate: (data['checklistDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ChecklistStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ChecklistStatus.pending,
      ),
      generalObservations: data['generalObservations'],
      items: (data['items'] as List<dynamic>?)
              ?.map((itemData) => ChecklistItem.fromFirestore(itemData))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Checklist copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DateTime? checklistDate,
    ChecklistStatus? status,
    String? generalObservations,
    List<ChecklistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Checklist(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      checklistDate: checklistDate ?? this.checklistDate,
      status: status ?? this.status,
      generalObservations: generalObservations ?? this.generalObservations,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}