import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checklist.dart';

class ChecklistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'checklists';

  // Criar checklist (com validação de unidade)
  Future<void> createChecklist(Checklist checklist) async {
    try {
      // Validar se unitId está presente
      if (checklist.unitId.isEmpty) {
        throw Exception('ID da unidade é obrigatório');
      }
      await _firestore.collection(_collection).add(checklist.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar checklist: $e');
    }
  }

  // Obter todos os checklists (filtrado por unidade)
  Stream<List<Checklist>> getChecklists({String? unitId}) {
    Query query = _firestore.collection(_collection);
    
    // Filtrar por unidade se especificado
    if (unitId != null && unitId.isNotEmpty) {
      query = query.where('unitId', isEqualTo: unitId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Checklist.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Obter checklists por veículo (filtrado por unidade)
  Stream<List<Checklist>> getChecklistsByVehicleId(String vehicleId, {String? unitId}) {
    Query query = _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId);
    
    // Filtrar por unidade se especificado
    if (unitId != null && unitId.isNotEmpty) {
      query = query.where('unitId', isEqualTo: unitId);
    }
    
    return query
        .orderBy('checklistDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Checklist.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Buscar checklist por ID (com verificação de unidade)
  Future<Checklist?> getChecklistById(String id, {String? unitId}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final checklist = Checklist.fromFirestore(data, doc.id);
        
        // Verificar se o checklist pertence à unidade especificada
        if (unitId != null && checklist.unitId != unitId) {
          return null; // Checklist não pertence à unidade
        }
        
        return checklist;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar checklist: $e');
    }
  }

  // Atualizar checklist
  Future<void> updateChecklist(Checklist checklist) async {
    try {
      await _firestore.collection(_collection).doc(checklist.id).update(checklist.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar checklist: $e');
    }
  }

  // Deletar checklist
  Future<void> deleteChecklist(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar checklist: $e');
    }
  }
}