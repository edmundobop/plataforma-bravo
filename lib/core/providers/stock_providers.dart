import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../services/stock_movement_service.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

// Provider para o ProductService
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Provider para o StockMovementService
final stockMovementServiceProvider = Provider<StockMovementService>((ref) {
  return StockMovementService();
});

// Provider para stream de produtos
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProducts();
});

// Provider para produtos com estoque baixo
final lowStockProductsProvider = StreamProvider<List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getLowStockProducts();
});

// Provider para produtos com estoque baixo (stream)
final lowStockProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getLowStockProducts();
});

// Provider para produtos com estoque crítico
final criticalStockProductsProvider = StreamProvider<List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getCriticalStockProducts();
});

// Provider para estatísticas de estoque
final stockStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getStockStats();
});

// Provider para stream de movimentações
final movementsStreamProvider = StreamProvider<List<StockMovement>>((ref) {
  final movementService = ref.watch(stockMovementServiceProvider);
  return movementService.getMovements();
});

// Provider para movimentações recentes
final recentMovementsProvider = StreamProvider<List<StockMovement>>((ref) {
  final movementService = ref.watch(stockMovementServiceProvider);
  return movementService.getRecentMovements(limit: 5);
});

// Provider para movimentações recentes (stream)
final recentMovementsStreamProvider = StreamProvider<List<StockMovement>>((ref) {
  final movementService = ref.watch(stockMovementServiceProvider);
  return movementService.getRecentMovements(limit: 5);
});

// Provider para estatísticas de movimentação
final movementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final movementService = ref.watch(stockMovementServiceProvider);
  return movementService.getMovementStats();
});

// Provider para busca de produtos
final productSearchProvider = StreamProvider.family<List<Product>, String>((ref, query) {
  final productService = ref.watch(productServiceProvider);
  if (query.isEmpty) {
    return productService.getProducts();
  }
  return productService.searchProducts(query);
});

// Provider para produtos por categoria
final productsByCategoryProvider = StreamProvider.family<List<Product>, String>((ref, category) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsByCategory(category);
});

// Provider para movimentações por produto
final movementsByProductProvider = StreamProvider.family<List<StockMovement>, String>((ref, productId) {
  final movementService = ref.watch(stockMovementServiceProvider);
  return movementService.getMovementsByProduct(productId);
});

// Providers para filtros e busca
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String>((ref) => 'Todas');

// Provider para categorias
final categoriesProvider = Provider<List<String>>((ref) {
  return [
    'Todas',
    'APH',
    'Alimentício',
    'Limpeza',
    'Escritório',
    'Manutenção',
    'Outros',
  ];
});

// Provider para produtos filtrados
final filteredProductsProvider = StreamProvider<List<Product>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final productService = ref.watch(productServiceProvider);
  
  return productService.getProducts().map((products) {
    var filtered = products;
    
    // Filtrar por categoria
    if (categoryFilter.isNotEmpty && categoryFilter != 'Todas') {
      filtered = filtered.where((product) => product.category == categoryFilter).toList();
    }
    
    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  });
});