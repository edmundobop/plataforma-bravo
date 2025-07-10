import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_movement_service.dart';
import '../models/stock_movement.dart';

// Provider para o serviço de movimentação de estoque
final stockMovementServiceProvider = Provider<StockMovementService>((ref) {
  return StockMovementService();
});

// Provider para movimentações recentes (consulta simples)
final recentMovementsProvider = StreamProvider.family<List<StockMovement>, int>((ref, limit) {
  final service = ref.watch(stockMovementServiceProvider);
  return service.getRecentMovementsStream(limit: limit);
});

// Provider para movimentações de um usuário específico
final userMovementsProvider = StreamProvider.family<List<StockMovement>, String>((ref, userId) {
  final service = ref.watch(stockMovementServiceProvider);
  return service.getUserMovementsStream(userId);
});

// Provider para estatísticas básicas
final movementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(stockMovementServiceProvider);
  return service.getRealStats();
});

// Provider para movimentações recentes com limite padrão
final defaultRecentMovementsProvider = StreamProvider<List<StockMovement>>((ref) {
  final service = ref.watch(stockMovementServiceProvider);
  return service.getRecentMovementsStream(limit: 5); // Apenas 5 para performance
});