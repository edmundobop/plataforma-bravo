import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

// Provider para o serviço de produtos
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Provider para stream de produtos
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsStream();
});

// Provider para categorias
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  return productService.getCategories();
});

// Provider para query de busca
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider para filtro de categoria
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Provider para produtos filtrados
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);

  return productsAsync.when(
    data: (products) {
      var filteredProducts = products;

      // Filtrar por categoria
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        filteredProducts = filteredProducts
            .where((product) => product.category == categoryFilter)
            .toList();
      }

      // Filtrar por busca
      if (searchQuery.isNotEmpty) {
        filteredProducts = filteredProducts
            .where((product) =>
                product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                product.description.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      return AsyncValue.data(filteredProducts);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider para produtos com baixo estoque
final lowStockProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  
  return productsAsync.when(
    data: (products) {
      final lowStockProducts = products.where((product) => 
        product.currentStock <= product.minStock
      ).toList();
      return AsyncValue.data(lowStockProducts);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider para produtos em estoque crítico
final criticalStockProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  
  return productsAsync.when(
    data: (products) {
      final criticalProducts = products.where((product) => 
        product.currentStock == 0
      ).toList();
      return AsyncValue.data(criticalProducts);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});