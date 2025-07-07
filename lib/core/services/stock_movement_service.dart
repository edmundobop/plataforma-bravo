import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_movement.dart';

class StockMovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stock_movements';

  // Criar múltiplas movimentações em lote (SEM CONSULTAS AUTOMÁTICAS)
  Future<void> createMovementsBatch(List<StockMovement> movements) async {
    try {
      final batch = _firestore.batch();
      
      for (final movement in movements) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, movement.toMap());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar movimentações em lote: $e');
    }
  }

  // Método para obter estatísticas básicas (SEM CONSULTAS COMPLEXAS)
  Future<Map<String, dynamic>> getBasicStats() async {
    try {
      // Retorna dados estáticos para evitar consultas complexas
      // Exemplo corrigido sem uso de toMap
      return {
        'totalMovements': 0,
        'entries': 0,
        'exits': 0,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}