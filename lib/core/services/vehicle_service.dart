import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehicles';

  // Criar veículo (com validação de unidade)
  Future<void> createVehicle(Vehicle vehicle) async {
    try {
      // Validar se unitId está presente
      if (vehicle.unitId.isEmpty) {
        throw Exception('ID da unidade é obrigatório');
      }
      await _firestore.collection(_collection).add(vehicle.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar veículo: $e');
    }
  }

  // Obter todos os veículos (filtrado por unidade)
  Stream<List<Vehicle>> getVehicles({String? unitId}) {
    Query query = _firestore.collection(_collection);
    
    // Filtrar por unidade se especificado
    if (unitId != null && unitId.isNotEmpty) {
      query = query.where('unitId', isEqualTo: unitId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Vehicle.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Buscar veículo por ID (com verificação de unidade)
  Future<Vehicle?> getVehicleById(String id, {String? unitId}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final vehicle = Vehicle.fromFirestore(data, doc.id);
        
        // Verificar se o veículo pertence à unidade especificada
        if (unitId != null && vehicle.unitId != unitId) {
          return null; // Veículo não pertence à unidade
        }
        
        return vehicle;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar veículo: $e');
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