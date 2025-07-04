import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checklist.dart';

class ChecklistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'checklists';

  // Create Checklist
  Future<void> createChecklist(Checklist checklist) async {
    try {
      await _firestore.collection(_collection).add(checklist.toFirestore());
    } catch (e) {
      throw Exception('Error creating checklist: $e');
    }
  }

  // Get all checklists
  Stream<List<Checklist>> getChecklists() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Checklist.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Get checklists by vehicle ID
  Stream<List<Checklist>> getChecklistsByVehicleId(String vehicleId) {
    return _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('checklistDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Checklist.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Get a single checklist by ID
  Future<Checklist?> getChecklistById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Checklist.fromFirestore(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting checklist by ID: $e');
    }
  }

  // Update Checklist
  Future<void> updateChecklist(Checklist checklist) async {
    try {
      await _firestore.collection(_collection).doc(checklist.id).update(checklist.toFirestore());
    } catch (e) {
      throw Exception('Error updating checklist: $e');
    }
  }

  // Delete Checklist
  Future<void> deleteChecklist(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting checklist: $e');
    }
  }
}