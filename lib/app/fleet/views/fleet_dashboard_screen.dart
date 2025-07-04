import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/providers/providers.dart';
import '../../../features/checklist_viaturas/screens/checklist_setup_screen.dart';

class FleetDashboardScreen extends ConsumerStatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  ConsumerState<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends ConsumerState<FleetDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const _DashboardOverview(),
      const _VehicleListSection(),
      const _VehicleChecklistSection(),
      // Add other sections here as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist de Viaturas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Voltar ao Menu Principal',
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car),
                label: Text('Viaturas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_box),
                label: Text('Checklists'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Viaturas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Visão Geral do Checklist de Viaturas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Em desenvolvimento...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleListSection extends ConsumerWidget {
  const _VehicleListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Viaturas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma viatura cadastrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(vehicle.type.toString().split('.').last.toUpperCase()),
                  ),
                  title: Text('${vehicle.name} - ${vehicle.licensePlate}'),
                  subtitle: Text('Modelo: ${vehicle.model} (${vehicle.year})'),
                  trailing: Consumer(
                    builder: (context, ref, child) {
                      final isAdmin = ref.watch(isAdminProvider);
                      return PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              context.push('/fleet/vehicle-registration', extra: vehicle);
                              break;
                            case 'delete':
                              _deleteVehicle(context, ref, vehicle);
                              break;
                            case 'perform_checklist':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChecklistSetupScreen(vehicle: vehicle),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'perform_checklist',
                            child: ListTile(
                              leading: Icon(Icons.checklist),
                              title: Text('Realizar Checklist'),
                            ),
                          ),
                          if (isAdmin)
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Editar'),
                              ),
                            ),
                          if (isAdmin)
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar viaturas: $error'),
              const SizedBox(height: 16),
              // You might want to add a retry button here
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isAdmin = ref.watch(isAdminProvider);
          return isAdmin
              ? FloatingActionButton(
                  onPressed: () {
                    context.push('/fleet/vehicle-registration');
                  },
                  child: const Icon(Icons.add),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _deleteVehicle(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a viatura "${vehicle.licensePlate}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final vehicleService = ref.read(vehicleServiceProvider);
                await vehicleService.deleteVehicle(vehicle.id!);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viatura excluída com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir viatura: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _VehicleChecklistSection extends ConsumerWidget {
  const _VehicleChecklistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistsAsync = ref.watch(checklistsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklists de Viaturas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: checklistsAsync.when(
        data: (checklists) {
          if (checklists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_box, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum checklist registrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: checklists.length,
            itemBuilder: (context, index) {
              final checklist = checklists[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(checklist.status.toString().split('.').last.toUpperCase().substring(0, 1)),
                  ),
                  title: FutureBuilder<Vehicle?>(
                    future: ref.watch(vehicleServiceProvider).getVehicleById(checklist.vehicleId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Carregando...');
                      } else if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Text('${snapshot.data!.name} - ${snapshot.data!.licensePlate}');
                      } else {
                        return const Text('Viatura não encontrada');
                      }
                    },
                  ),
                  subtitle: Text('Data: ${checklist.checklistDate.toLocal().toString().split(' ')[0]} - Status: ${checklist.status.toString().split('.').last}'),
                  onTap: () {
                    context.push('/fleet/checklist-details/${checklist.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar checklists: $error'),
              const SizedBox(height: 16),
              // You might want to add a retry button here
            ],
          ),
        ),
      ),
    );
  }
}