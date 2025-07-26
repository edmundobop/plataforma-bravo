import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Obter todos os produtos (filtrado por unidade)
  Stream<List<Product>> getProducts({String? unitId}) {
    Query query = _firestore.collection(_collection);
    
    // Filtrar por unidade se especificado
    if (unitId != null && unitId.isNotEmpty) {
      query = query.where('unitId', isEqualTo: unitId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Método alternativo para compatibilidade
  Stream<List<Product>> getProductsStream() {
    return getProducts();
  }

  // Buscar produto por ID (com verificação de unidade)
  Future<Product?> getProductById(String id, {String? unitId}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final product = Product.fromFirestore(data, doc.id);
        
        // Verificar se o produto pertence à unidade especificada
        if (unitId != null && product.unitId != unitId) {
          return null; // Produto não pertence à unidade
        }
        
        return product;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  // Criar produto (com validação de unidade)
  Future<void> createProduct(Product product) async {
    try {
      // Validar se unitId está presente
      if (product.unitId.isEmpty) {
        throw Exception('ID da unidade é obrigatório');
      }
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

  // Buscar categorias (filtrado por unidade)
  Future<List<String>> getCategories({String? unitId}) async {
    try {
      // Sempre começar com as categorias padrão
      final categories = <String>{
        'Material de Escritório',
        'Equipamentos de Proteção',
        'Ferramentas',
        'Material de Limpeza',
        'Equipamentos Eletrônicos',
        'Material Médico',
        'Combustível',
        'Peças e Componentes',
        'Material de Construção',
        'Outros',
      };
      
      // Buscar categorias dos produtos existentes para adicionar às padrão
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      final snapshot = await query.get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
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

  // Buscar produtos por categoria (filtrado por unidade)
  Future<List<Product>> getProductsByCategory(String category, {String? unitId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.category == category)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos por categoria: $e');
    }
  }

  // Buscar produtos com estoque baixo (filtrado por unidade)
  Future<List<Product>> getLowStockProducts({String? unitId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.currentStock <= product.minStock)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos com estoque baixo: $e');
    }
  }

  // Buscar produtos em estoque crítico (filtrado por unidade)
  Future<List<Product>> getCriticalStockProducts({String? unitId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.currentStock == 0)
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos em estoque crítico: $e');
    }
  }

  // Buscar produtos por nome (filtrado por unidade)
  Future<List<Product>> searchProductsByName(String name, {String? unitId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filtrar por unidade se especificado
      if (unitId != null && unitId.isNotEmpty) {
        query = query.where('unitId', isEqualTo: unitId);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
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