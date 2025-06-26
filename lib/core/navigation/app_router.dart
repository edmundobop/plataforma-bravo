import 'package:go_router/go_router.dart';
import '../../app/home/views/home_screen.dart';
import '../../app/inspections/views/inspections_screen.dart';
import '../../app/stock/views/stock_dashboard_screen.dart';
import '../../app/stock/consumables/views/product_list_screen.dart';
import '../../app/stock/consumables/views/product_registration_screen.dart';
import '../../app/stock/consumables/views/stock_movement_screen.dart';
import '../../app/fleet/views/fleet_screen.dart';
import '../../app/trade_services/views/trade_services_screen.dart';
import '../models/models.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
      path: '/stock/products',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/stock/product-registration',
      builder: (context, state) {
        final product = state.extra as Product?;
        return ProductRegistrationScreen(product: product);
      },
    ),
    GoRoute(
      path: '/stock/movement',
      builder: (context, state) => const StockMovementScreen(),
    ),
    GoRoute(
      path: '/fleet',
      builder: (context, state) => const FleetScreen(),
    ),
    GoRoute(
      path: '/trade-services',
      builder: (context, state) => const TradeServicesScreen(),
    ),
  ],
);