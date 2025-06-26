import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Buscar todos os produtos
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
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

  // Buscar produtos por categoria
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Buscar produtos com estoque baixo
  Stream<List<Product>> getLowStockProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .where((product) => product.currentStock <= product.minStock)
            .toList());
  }

  // Buscar produtos com estoque crítico
  Stream<List<Product>> getCriticalStockProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .where((product) => product.currentStock < (product.minStock * 0.5))
            .toList());
  }

  // Buscar produtos por nome ou descrição
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Obter estatísticas de estoque
  Future<Map<String, int>> getStockStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      return {
        'total': products.length,
        'lowStock': products.where((p) => p.currentStock <= p.minStock).length,
        'critical': products.where((p) => p.currentStock < (p.minStock * 0.5)).length,
        'normal': products.where((p) => p.currentStock > p.minStock).length,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // Atualizar estoque do produto
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'currentStock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar estoque: $e');
    }
  }
}