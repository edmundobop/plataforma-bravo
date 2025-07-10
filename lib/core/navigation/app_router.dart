import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/auth/views/login_screen.dart';
import '../../app/auth/views/user_management_screen.dart';
import '../../app/home/views/home_screen.dart';
import '../../app/inspections/views/inspections_screen.dart';
import '../../app/stock/views/stock_dashboard_screen.dart';
import '../../app/fleet/views/fleet_dashboard_screen.dart';
import '../../app/trade_services/views/trade_services_screen.dart';
import '../../app/stock/consumables/views/product_registration_screen.dart';
import '../../app/stock/consumables/views/product_list_screen.dart';
import '../../app/stock/consumables/views/stock_movement_screen.dart';
import '../../app/fleet/views/vehicle_registration_screen.dart';
import '../../app/fleet/views/checklist_form_screen.dart';
import '../../app/fleet/views/checklist_details_screen.dart';
import '../../core/models/product.dart';
import '../../core/models/vehicle.dart';
import '../providers/auth_providers.dart';
import '../../app/profile/views/profile_screen.dart';

// Provider do router
final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Se não estiver logado e não estiver na tela de login
      if (!isLoggedIn && state.matchedLocation != '/login') {
        return '/login';
      }

      // Se estiver logado e estiver na tela de login
      if (isLoggedIn && state.matchedLocation == '/login') {
        return '/';
      }

      return null; // Não redirecionar
    },
    routes: [
      // Rota de login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Rotas principais (protegidas)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/inspections',
        builder: (context, state) => const InspectionsScreen(),
      ),
      GoRoute(
        path: '/stock',
        builder: (context, state) => const StockDashboardScreen(),
        routes: [
          GoRoute(
            path: 'product-registration',
            builder: (context, state) {
              final product = state.extra as Product?;
              return ProductRegistrationScreen(product: product);
            },
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: 'movement',
            builder: (context, state) => const StockMovementScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/fleet',
        builder: (context, state) => const FleetDashboardScreen(),
        routes: [
          GoRoute(
            path: 'vehicle-registration',
            builder: (context, state) {
              final vehicle = state.extra as Vehicle?;
              return VehicleRegistrationScreen(vehicle: vehicle);
            },
          ),
          GoRoute(
            path: 'checklist-form/:vehicleId',
            builder: (context, state) => ChecklistFormScreen(
              vehicleId: state.pathParameters['vehicleId']!,
            ),
          ),
          GoRoute(
            path: 'checklist-details/:checklistId',
            builder: (context, state) => ChecklistDetailsScreen(
              checklistId: state.pathParameters['checklistId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/trade-services',
        builder: (context, state) => const TradeServicesScreen(),
      ),
      // Rota de perfil do usuário
      // Esta rota pode ser acessada por qualquer usuário logado
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Rota de gerenciamento de usuários (apenas admin)
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
  );
});

// Widget wrapper para o router
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gestão CBM-GO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
