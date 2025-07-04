import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../services/checklist_service.dart';

// Provider for ChecklistService
final checklistServiceProvider = Provider<ChecklistService>((ref) => ChecklistService());

// StreamProvider for all checklists
final checklistsStreamProvider = StreamProvider<List<Checklist>>((ref) {
  final checklistService = ref.watch(checklistServiceProvider);
  return checklistService.getChecklists();
});

// StreamProvider for checklists by vehicle ID
final checklistsByVehicleProvider = StreamProvider.family<List<Checklist>, String>((ref, vehicleId) {
  final checklistService = ref.watch(checklistServiceProvider);
  return checklistService.getChecklistsByVehicleId(vehicleId);
});