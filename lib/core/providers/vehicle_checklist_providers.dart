import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vehicle_checklist_service.dart';
import '../../features/checklist_viaturas/models/vehicle_checklist.dart';
import 'fire_unit_providers.dart';

// Provider do serviço
final vehicleChecklistServiceProvider = Provider<VehicleChecklistService>((ref) {
  return VehicleChecklistService();
});

// Provider para obter checklists da unidade atual
final vehicleChecklistsProvider = FutureProvider<List<VehicleChecklist>>((ref) async {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  if (currentUnitId == null) {
    return [];
  }
  
  return service.getVehicleChecklistsByUnit(currentUnitId);
});

// Provider para observar checklists em tempo real
final vehicleChecklistsStreamProvider = StreamProvider<List<VehicleChecklist>>((ref) {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  if (currentUnitId == null) {
    return Stream.value([]);
  }
  
  return service.watchVehicleChecklistsByUnit(currentUnitId);
});

// Provider para obter checklists de um veículo específico
final vehicleChecklistsByVehicleProvider = FutureProvider.family<List<VehicleChecklist>, String>((ref, vehicleId) async {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  if (currentUnitId == null) {
    return [];
  }
  
  return service.getVehicleChecklistsByVehicle(currentUnitId, vehicleId);
});

// Provider para obter um checklist específico
final vehicleChecklistByIdProvider = FutureProvider.family<VehicleChecklist?, String>((ref, checklistId) async {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  if (currentUnitId == null) {
    return null;
  }
  
  return service.getVehicleChecklistById(checklistId, currentUnitId);
});

// Provider para estatísticas de checklists
final vehicleChecklistStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  if (currentUnitId == null) {
    return {'total': 0, 'completed': 0, 'pending': 0};
  }
  
  return service.getChecklistStatsByUnit(currentUnitId);
});

// Provider para criar um novo checklist
final createVehicleChecklistProvider = Provider<Future<String> Function(VehicleChecklist)>((ref) {
  final service = ref.read(vehicleChecklistServiceProvider);
  
  return (VehicleChecklist checklist) async {
    final checklistId = await service.createVehicleChecklist(checklist);
    
    // Invalidar os providers para atualizar a lista
    ref.invalidate(vehicleChecklistsProvider);
    ref.invalidate(vehicleChecklistStatsProvider);
    
    return checklistId;
  };
});

// Provider para atualizar um checklist
final updateVehicleChecklistProvider = Provider<Future<void> Function(VehicleChecklist)>((ref) {
  final service = ref.read(vehicleChecklistServiceProvider);
  
  return (VehicleChecklist checklist) async {
    await service.updateVehicleChecklist(checklist);
    
    // Invalidar os providers para atualizar a lista
    ref.invalidate(vehicleChecklistsProvider);
    ref.invalidate(vehicleChecklistStatsProvider);
    if (checklist.id != null) {
      ref.invalidate(vehicleChecklistByIdProvider(checklist.id!));
    }
    if (checklist.vehicleId.isNotEmpty) {
      ref.invalidate(vehicleChecklistsByVehicleProvider(checklist.vehicleId));
    }
  };
});

// Provider para deletar um checklist
final deleteVehicleChecklistProvider = Provider<Future<void> Function(String)>((ref) {
  final service = ref.read(vehicleChecklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  return (String checklistId) async {
    if (currentUnitId == null) {
      throw Exception('Unidade atual não encontrada');
    }
    
    await service.deleteVehicleChecklist(checklistId, currentUnitId);
    
    // Invalidar os providers para atualizar a lista
    ref.invalidate(vehicleChecklistsProvider);
    ref.invalidate(vehicleChecklistStatsProvider);
    ref.invalidate(vehicleChecklistByIdProvider(checklistId));
  };
});