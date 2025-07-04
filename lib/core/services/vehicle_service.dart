import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehicles';

  // Create Vehicle
  Future<void> createVehicle(Vehicle vehicle) async {
    try {
      await _firestore.collection(_collection).add(vehicle.toFirestore());
    } catch (e) {
      throw Exception('Error creating vehicle: $e');
    }
  }

  // Get all vehicles
  Stream<List<Vehicle>> getVehicles() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Get a single vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Vehicle.fromFirestore(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting vehicle by ID: $e');
    }
  }

  // Update Vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _firestore.collection(_collection).doc(vehicle.id).update(vehicle.toFirestore());
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }

  // Delete Vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }
}