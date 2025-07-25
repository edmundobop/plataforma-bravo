import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_movement.dart';

class StockMovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stock_movements';

  // Criar movimentação (com validação de unidade)
  Future<void> createMovement(StockMovement movement) async {
    try {
      // Validar se unitId está presente
      if (movement.unitId.isEmpty) {
        throw Exception('ID da unidade é obrigatório');
      }
      await _firestore.collection(_collection).add(movement.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar movimentação: $e');
    }
  }

  // Criar múltiplas movimentações em lote (SEM CONSULTAS AUTOMÁTICAS)
  Future<void> createMovementsBatch(List<StockMovement> movements) async {
    try {
      final batch = _firestore.batch();
      
      for (final movement in movements) {
        // Validar se unitId está presente
        if (movement.unitId.isEmpty) {
          throw Exception('ID da unidade é obrigatório para todas as movimentações');
        }
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, movement.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar movimentações em lote: $e');
    }
  }

  // Buscar movimentação por ID (com verificação de unidade)
  Future<StockMovement?> getMovementById(String id, {String? unitId}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final movement = StockMovement.fromFirestore(data, doc.id);
        
        // Verificar se a movimentação pertence à unidade especificada
        if (unitId != null && movement.unitId != unitId) {
          return null; // Movimentação não pertence à unidade
        }
        
        return movement;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar movimentação: $e');
    }
  }

  // Método para obter estatísticas básicas (SEM CONSULTAS COMPLEXAS)
  Future<Map<String, dynamic>> getBasicStats() async {
    try {
      // Retorna dados estáticos para evitar consultas complexas
      return {
        'totalMovements': 0,
        'entries': 0,
        'exits': 0,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // Obter movimentações recentes (filtrado por unidade)
  Stream<List<StockMovement>> getRecentMovementsStream({String? unitId, int limit = 10}) {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      return query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return StockMovement.fromFirestore(data, doc.id);
        }).toList();
      });
    } catch (e) {
      throw Exception('Erro ao obter movimentações recentes: $e');
    }
  }

  // Obter movimentações do usuário (filtrado por unidade)
  Stream<List<StockMovement>> getUserMovementsStream(String userId, {String? unitId, int limit = 20}) {
    try {
      Query query = _firestore.collection(_collection).where('userId', isEqualTo: userId);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      return query
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        final movements = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return StockMovement.fromFirestore(data, doc.id);
        }).toList();
        
        // Ordenar no cliente para evitar índice composto
        movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return movements;
      });
    } catch (e) {
      throw Exception('Erro ao obter movimentações do usuário: $e');
    }
  }

  // Método para obter estatísticas reais (consulta simples)
  Future<Map<String, dynamic>> getRealStats() async {
    try {
      // Consulta simples para contar documentos
      final snapshot = await _firestore
          .collection(_collection)
          .limit(100) // Limitar para performance
          .get();

      final movements = snapshot.docs.map((doc) {
        final data = doc.data();
        return StockMovement.fromFirestore(data, doc.id);
      }).toList();

      final totalMovements = movements.length;
      final entries = movements.where((m) => m.type.toString().split('.').last == 'entry').length;
      final exits = movements.where((m) => m.type.toString().split('.').last == 'exit').length;

      return {
        'totalMovements': totalMovements,
        'entries': entries,
        'exits': exits,
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // Em caso de erro, retorna dados básicos
      return {
        'totalMovements': 0,
        'entries': 0,
        'exits': 0,
        'error': e.toString(),
      };
    }
  }
}