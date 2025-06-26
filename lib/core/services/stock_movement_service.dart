import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_movement.dart';

class StockMovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stock_movements';

  // Criar movimentação
  Future<void> createMovement(StockMovement movement) async {
    try {
      // Iniciar transação para garantir consistência
      await _firestore.runTransaction((transaction) async {
        // Adicionar a movimentação
        final movementRef = _firestore.collection(_collection).doc();
        transaction.set(movementRef, movement.toFirestore());

        // Atualizar o estoque do produto
        final productRef = _firestore.collection('products').doc(movement.productId);
        final productDoc = await transaction.get(productRef);
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()!['currentStock'] as int;
          int newStock;
          
          if (movement.type == MovementType.entry) {
            newStock = currentStock + movement.quantity;
          } else {
            newStock = currentStock - movement.quantity;
            if (newStock < 0) {
              throw Exception('Estoque insuficiente para esta operação');
            }
          }
          
          transaction.update(productRef, {
            'currentStock': newStock,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          throw Exception('Produto não encontrado');
        }
      });
    } catch (e) {
      throw Exception('Erro ao criar movimentação: $e');
    }
  }

  // Buscar todas as movimentações
  Stream<List<StockMovement>> getMovements() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Buscar movimentações por produto
  Stream<List<StockMovement>> getMovementsByProduct(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Buscar movimentações por tipo
  Stream<List<StockMovement>> getMovementsByType(MovementType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Buscar movimentações por período
  Stream<List<StockMovement>> getMovementsByDateRange(DateTime start, DateTime end) {
    return _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Buscar movimentações recentes
  Stream<List<StockMovement>> getRecentMovements({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Deletar movimentação (com reversão de estoque)
  Future<void> deleteMovement(String id) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Buscar a movimentação
        final movementRef = _firestore.collection(_collection).doc(id);
        final movementDoc = await transaction.get(movementRef);
        
        if (!movementDoc.exists) {
          throw Exception('Movimentação não encontrada');
        }
        
        final movement = StockMovement.fromFirestore(movementDoc.data()!, movementDoc.id);
        
        // Reverter o estoque
        final productRef = _firestore.collection('products').doc(movement.productId);
        final productDoc = await transaction.get(productRef);
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()!['currentStock'] as int;
          int newStock;
          
          // Reverter a operação
          if (movement.type == MovementType.entry) {
            newStock = currentStock - movement.quantity;
            if (newStock < 0) {
              throw Exception('Não é possível reverter: estoque ficaria negativo');
            }
          } else {
            newStock = currentStock + movement.quantity;
          }
          
          transaction.update(productRef, {
            'currentStock': newStock,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Deletar a movimentação
        transaction.delete(movementRef);
      });
    } catch (e) {
      throw Exception('Erro ao deletar movimentação: $e');
    }
  }

  // Obter estatísticas de movimentação
  Future<Map<String, dynamic>> getMovementStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final movements = snapshot.docs
          .map((doc) => StockMovement.fromFirestore(doc.data(), doc.id))
          .toList();

      final entries = movements.where((m) => m.type == MovementType.entry);
      final exits = movements.where((m) => m.type == MovementType.exit);

      return {
        'totalMovements': movements.length,
        'totalEntries': entries.length,
        'totalExits': exits.length,
        'totalEntryQuantity': entries.fold<int>(0, (total, m) => total + m.quantity),
        'totalExitQuantity': exits.fold<int>(0, (total, m) => total + m.quantity),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas de movimentação: $e');
    }
  }

  // Buscar movimentações do mês atual
  Stream<List<StockMovement>> getCurrentMonthMovements() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getMovementsByDateRange(startOfMonth, endOfMonth);
  }

  // Buscar movimentações da semana atual
  Stream<List<StockMovement>> getCurrentWeekMovements() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return getMovementsByDateRange(startOfWeek, endOfWeek);
  }
}