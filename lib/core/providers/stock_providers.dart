import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_movement_service.dart';

// Provider para o serviço de movimentação de estoque
final stockMovementServiceProvider = Provider<StockMovementService>((ref) {
  return StockMovementService();
});

// Provider básico com dados estáticos (SEM CONSULTAS FIRESTORE)
final basicStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'totalMovements': 0,
    'entries': 0,
    'exits': 0,
  };
});