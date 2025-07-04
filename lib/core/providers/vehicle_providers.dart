import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

// Provider for VehicleService
final vehicleServiceProvider = Provider<VehicleService>((ref) => VehicleService());

// StreamProvider for all vehicles
final vehiclesStreamProvider = StreamProvider<List<Vehicle>>((ref) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehicles();
});