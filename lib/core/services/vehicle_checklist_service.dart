import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/checklist_viaturas/models/vehicle_checklist.dart';

class VehicleChecklistService {
  static const String _collection = 'vehicle_checklists';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar um novo checklist de veículo
  Future<String> createVehicleChecklist(VehicleChecklist checklist) async {
    try {
      // Validar se o unitId foi fornecido
      if (checklist.unitId.isEmpty) {
        throw Exception('Unit ID é obrigatório para criar um checklist de veículo');
      }

      final checklistData = checklist.toMap();
      checklistData['createdAt'] = FieldValue.serverTimestamp();
      checklistData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(_collection)
          .add(checklistData);

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar checklist de veículo: $e');
    }
  }

  // Atualizar um checklist de veículo existente
  Future<void> updateVehicleChecklist(VehicleChecklist checklist) async {
    try {
      if (checklist.id == null || checklist.id!.isEmpty) {
        throw Exception('ID do checklist é obrigatório para atualização');
      }

      if (checklist.unitId.isEmpty) {
        throw Exception('Unit ID é obrigatório para atualizar um checklist de veículo');
      }

      final checklistData = checklist.toMap();
      checklistData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(checklist.id)
          .update(checklistData);
    } catch (e) {
      throw Exception('Erro ao atualizar checklist de veículo: $e');
    }
  }

  // Obter checklists de veículo por unidade
  Future<List<VehicleChecklist>> getVehicleChecklistsByUnit(String unitId) async {
    try {
      if (unitId.isEmpty) {
        throw Exception('Unit ID é obrigatório para buscar checklists');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VehicleChecklist.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar checklists de veículo: $e');
    }
  }

  // Obter checklists de veículo por veículo específico
  Future<List<VehicleChecklist>> getVehicleChecklistsByVehicle(
    String unitId,
    String vehicleId,
  ) async {
    try {
      if (unitId.isEmpty || vehicleId.isEmpty) {
        throw Exception('Unit ID e Vehicle ID são obrigatórios');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VehicleChecklist.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar checklists do veículo: $e');
    }
  }

  // Obter um checklist específico
  Future<VehicleChecklist?> getVehicleChecklistById(
    String checklistId,
    String unitId,
  ) async {
    try {
      if (checklistId.isEmpty || unitId.isEmpty) {
        throw Exception('Checklist ID e Unit ID são obrigatórios');
      }

      final doc = await _firestore
          .collection(_collection)
          .doc(checklistId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final checklist = VehicleChecklist.fromMap(doc.data()!, doc.id);
      
      // Verificar se o checklist pertence à unidade correta
      if (checklist.unitId != unitId) {
        throw Exception('Acesso negado: checklist não pertence à unidade atual');
      }

      return checklist;
    } catch (e) {
      throw Exception('Erro ao buscar checklist: $e');
    }
  }

  // Deletar um checklist de veículo
  Future<void> deleteVehicleChecklist(String checklistId, String unitId) async {
    try {
      if (checklistId.isEmpty || unitId.isEmpty) {
        throw Exception('Checklist ID e Unit ID são obrigatórios');
      }

      // Primeiro verificar se o checklist pertence à unidade
      final checklist = await getVehicleChecklistById(checklistId, unitId);
      if (checklist == null) {
        throw Exception('Checklist não encontrado ou não pertence à unidade atual');
      }

      await _firestore
          .collection(_collection)
          .doc(checklistId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar checklist: $e');
    }
  }

  // Stream para observar checklists em tempo real
  Stream<List<VehicleChecklist>> watchVehicleChecklistsByUnit(String unitId) {
    if (unitId.isEmpty) {
      throw Exception('Unit ID é obrigatório para observar checklists');
    }

    return _firestore
        .collection(_collection)
        .where('unitId', isEqualTo: unitId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleChecklist.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obter estatísticas de checklists por unidade
  Future<Map<String, int>> getChecklistStatsByUnit(String unitId) async {
    try {
      if (unitId.isEmpty) {
        throw Exception('Unit ID é obrigatório para obter estatísticas');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .get();

      int total = querySnapshot.docs.length;
      int completed = querySnapshot.docs
          .where((doc) => doc.data()['isCompleted'] == true)
          .length;
      int pending = total - completed;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}