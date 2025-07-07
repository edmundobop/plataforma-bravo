import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Buscar todos os produtos (SEM QUALQUER ORDENAÇÃO OU FILTRO)
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Método alternativo para compatibilidade
  Stream<List<Product>> getProductsStream() {
    return getProducts();
  }

  // Buscar produto por ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  // Criar produto
  Future<void> createProduct(Product product) async {
    try {
      await _firestore.collection(_collection).add(product.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  // Atualizar produto
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('ID do produto não pode ser nulo');
      }
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  // Deletar produto
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar produto: $e');
    }
  }

  // Buscar categorias (PROCESSAMENTO NO CLIENTE)
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final categories = <String>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }
      
      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  // TODOS OS MÉTODOS ABAIXO FAZEM PROCESSAMENTO NO CLIENTE
  // PARA EVITAR CONSULTAS COMPLEXAS NO FIRESTORE

  // Buscar produtos por categoria (PROCESSAMENTO NO CLIENTE)
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) => product.category == category)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos por categoria: $e');
    }
  }

  // Buscar produtos com estoque baixo (PROCESSAMENTO NO CLIENTE)
  Future<List<Product>> getLowStockProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) => product.currentStock <= product.minStock)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos com estoque baixo: $e');
    }
  }

  // Buscar produtos em estoque crítico (PROCESSAMENTO NO CLIENTE)
  Future<List<Product>> getCriticalStockProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) => product.currentStock == 0)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos em estoque crítico: $e');
    }
  }

  // Buscar produtos por nome (PROCESSAMENTO NO CLIENTE)
  Future<List<Product>> searchProductsByName(String name) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) => 
              product.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  // Obter estatísticas básicas (PROCESSAMENTO NO CLIENTE)
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      final totalProducts = products.length;
      final lowStockProducts = products
          .where((p) => p.currentStock <= p.minStock)
          .length;
      final criticalStockProducts = products
          .where((p) => p.currentStock == 0)
          .length;
      final totalValue = products.fold<double>(
          0, (total, product) => total + (product.currentStock * 10.0));

      return {
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'criticalStockProducts': criticalStockProducts,
        'totalValue': totalValue,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}