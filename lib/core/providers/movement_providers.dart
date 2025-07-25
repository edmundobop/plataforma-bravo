import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_movement_service.dart';
import '../models/stock_movement.dart';
import 'fire_unit_providers.dart';

// Provider para o serviço de movimentação de estoque
final movementServiceProvider = Provider<StockMovementService>((ref) {
  return StockMovementService();
});

// Provider para movimentações recentes (consulta simples)
final recentMovementsProvider = StreamProvider.family<List<StockMovement>, int>((ref, limit) {
  final service = ref.watch(movementServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  return service.getRecentMovementsStream(unitId: currentUnitId, limit: limit);
});

// Provider para movimentações de um usuário específico
final userMovementsProvider = StreamProvider.family<List<StockMovement>, String>((ref, userId) {
  final service = ref.watch(movementServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  return service.getUserMovementsStream(userId, unitId: currentUnitId);
});

// Provider para estatísticas básicas
final movementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(movementServiceProvider);
  return service.getRealStats();
});

// Provider para movimentações recentes com limite padrão
final defaultRecentMovementsProvider = StreamProvider<List<StockMovement>>((ref) {
  final service = ref.watch(movementServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  return service.getRecentMovementsStream(unitId: currentUnitId, limit: 5); // Apenas 5 para performance
});