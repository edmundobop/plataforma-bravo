import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../services/checklist_service.dart';
import 'fire_unit_providers.dart';

// Provider for ChecklistService
final checklistServiceProvider = Provider<ChecklistService>((ref) => ChecklistService());

// StreamProvider for all checklists
final checklistsStreamProvider = StreamProvider<List<Checklist>>((ref) {
  final checklistService = ref.watch(checklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  return checklistService.getChecklists(unitId: currentUnitId);
});

// StreamProvider for checklists by vehicle ID
final checklistsByVehicleProvider = StreamProvider.family<List<Checklist>, String>((ref, vehicleId) {
  final checklistService = ref.watch(checklistServiceProvider);
  final currentUnitId = ref.watch(currentUnitIdProvider);
  return checklistService.getChecklistsByVehicleId(vehicleId, unitId: currentUnitId);
});