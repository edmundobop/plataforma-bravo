import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/auth/views/login_screen.dart';
import '../../app/auth/views/user_management_screen.dart';
import '../../app/home/views/home_screen.dart';
import '../../app/inspections/views/inspections_screen.dart';
import '../../app/stock/views/stock_dashboard_screen.dart';
import '../../app/fleet/views/fleet_screen.dart';
import '../../app/trade_services/views/trade_services_screen.dart';
import '../providers/auth_providers.dart';

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
      ),
      GoRoute(
        path: '/fleet',
        builder: (context, state) => const FleetScreen(),
      ),
      GoRoute(
        path: '/trade-services',
        builder: (context, state) => const TradeServicesScreen(),
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