import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fire_unit.dart';

class FireUnitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'fire_units';

  // Obter todas as unidades ativas
  static Stream<List<FireUnit>> getActiveUnits() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final units = snapshot.docs
              .map((doc) => FireUnit.fromFirestore(doc))
              .toList();
          
          // Ordenar por nome no código para evitar necessidade de índice
          units.sort((a, b) => a.name.compareTo(b.name));
          
          return units;
        });
  }

  // Obter unidade por ID
  static Future<FireUnit?> getUnitById(String unitId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(unitId).get();
      if (doc.exists) {
        return FireUnit.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar unidade: $e');
    }
  }

  // Obter múltiplas unidades por IDs
  static Future<List<FireUnit>> getUnitsByIds(List<String> unitIds) async {
    if (unitIds.isEmpty) return [];
    
    try {
      final List<FireUnit> units = [];
      
      // Firestore tem limite de 10 itens no operador 'in'
      // Dividir em chunks se necessário
      for (int i = 0; i < unitIds.length; i += 10) {
        final chunk = unitIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        units.addAll(snapshot.docs
            .map((doc) => FireUnit.fromFirestore(doc))
            .toList());
      }
      
      return units;
    } catch (e) {
      throw Exception('Erro ao buscar unidades: $e');
    }
  }

  // Criar nova unidade
  static Future<String> createUnit(FireUnit unit) async {
    try {
      final docRef = await _firestore.collection(_collection).add(unit.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar unidade: $e');
    }
  }

  // Atualizar unidade
  static Future<void> updateUnit(String unitId, FireUnit unit) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(unitId)
          .update(unit.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar unidade: $e');
    }
  }

  // Desativar unidade (soft delete)
  static Future<void> deactivateUnit(String unitId) async {
    try {
      await _firestore.collection(_collection).doc(unitId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao desativar unidade: $e');
    }
  }

  // Reativar unidade
  static Future<void> reactivateUnit(String unitId) async {
    try {
      await _firestore.collection(_collection).doc(unitId).update({
        'isActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao reativar unidade: $e');
    }
  }

  // Buscar unidades por cidade
  static Stream<List<FireUnit>> getUnitsByCity(String city) {
    return _firestore
        .collection(_collection)
        .where('city', isEqualTo: city)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final units = snapshot.docs
              .map((doc) => FireUnit.fromFirestore(doc))
              .toList();
          // Ordenar por nome no código para evitar necessidade de índice
          units.sort((a, b) => a.name.compareTo(b.name));
          return units;
        });
  }

  // Buscar unidades por código
  static Future<FireUnit?> getUnitByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final unit = FireUnit.fromFirestore(snapshot.docs.first);
        // Verificar se a unidade está ativa
        if (unit.isActive) {
          return unit;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar unidade por código: $e');
    }
  }

  // Verificar se código já existe
  static Future<bool> codeExists(String code, {String? excludeUnitId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('code', isEqualTo: code);
      
      if (excludeUnitId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeUnitId);
      }
      
      final snapshot = await query.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erro ao verificar código: $e');
    }
  }

  // Obter estatísticas das unidades
  static Future<Map<String, int>> getUnitsStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      int total = snapshot.docs.length;
      int active = snapshot.docs.where((doc) => doc.data()['isActive'] == true).length;
      int inactive = total - active;
      
      return {
        'total': total,
        'active': active,
        'inactive': inactive,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // Criar unidades padrão do CBMGO
  static Future<List<FireUnit>> createDefaultCBMGOUnits() async {
    final defaultUnits = [
      FireUnit(
        id: 'cbm-go-sede',
        name: 'Comando Geral do CBMGO',
        code: 'CG-CBMGO',
        address: 'Rua 1037, nº 230, Setor Pedro Ludovico',
        city: 'Goiânia',
        state: 'GO',
        phone: '(62) 3201-6500',
        email: 'comando@bombeiros.go.gov.br',
        commanderName: '',
        commanderRank: 'Coronel',
        createdAt: DateTime.now(),
      ),
      FireUnit(
        id: 'cbm-go-1gbm',
        name: '1º Grupamento de Bombeiros Militar',
        code: '1º GBM',
        address: 'Avenida Anhanguera, nº 5195, Setor Coimbra',
        city: 'Goiânia',
        state: 'GO',
        phone: '(62) 3201-6600',
        email: '1gbm@bombeiros.go.gov.br',
        commanderName: '',
        commanderRank: 'Tenente Coronel',
        createdAt: DateTime.now(),
      ),
      FireUnit(
        id: 'cbm-go-2gbm',
        name: '2º Grupamento de Bombeiros Militar',
        code: '2º GBM',
        address: 'Rua C-139, nº 456, Jardim América',
        city: 'Goiânia',
        state: 'GO',
        phone: '(62) 3201-6700',
        email: '2gbm@bombeiros.go.gov.br',
        commanderName: '',
        commanderRank: 'Tenente Coronel',
        createdAt: DateTime.now(),
      ),
      FireUnit(
        id: 'cbm-go-anapolis',
        name: 'Grupamento de Bombeiros de Anápolis',
        code: 'GB Anápolis',
        address: 'Avenida Brasil Norte, nº 1500, Centro',
        city: 'Anápolis',
        state: 'GO',
        phone: '(62) 3201-6800',
        email: 'anapolis@bombeiros.go.gov.br',
        commanderName: '',
        commanderRank: 'Major',
        createdAt: DateTime.now(),
      ),
    ];

    final createdUnits = <FireUnit>[];
    
    for (final unit in defaultUnits) {
      try {
        await createUnit(unit);
        createdUnits.add(unit);
      } catch (e) {
        // Se a unidade já existe, apenas adiciona à lista
        if (e.toString().contains('já existe')) {
          createdUnits.add(unit);
        } else {
          rethrow;
        }
      }
    }
    
    return createdUnits;
  }

  // Criar unidades padrão (para setup inicial)
  static Future<void> createDefaultUnits() async {
    try {
      // Verificar se já existem unidades
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return; // Já existem unidades
      }

      // Criar unidades padrão do CBMGO
      final defaultUnits = [
        FireUnit(
          id: '',
          name: '1º Grupamento de Bombeiros Militar',
          code: '1º GBM',
          address: 'Rua 84, nº 399, Setor Sul',
          city: 'Goiânia',
          state: 'GO',
          phone: '(62) 3201-6500',
          email: '1gbm@bombeiros.go.gov.br',
          commanderName: 'Comandante 1º GBM',
          commanderRank: 'Tenente Coronel',
          createdAt: DateTime.now(),
        ),
        FireUnit(
          id: '',
          name: '2º Grupamento de Bombeiros Militar',
          code: '2º GBM',
          address: 'Avenida Anhanguera, nº 5195, Setor Aeroviário',
          city: 'Goiânia',
          state: 'GO',
          phone: '(62) 3201-6600',
          email: '2gbm@bombeiros.go.gov.br',
          commanderName: 'Comandante 2º GBM',
          commanderRank: 'Tenente Coronel',
          createdAt: DateTime.now(),
        ),
        FireUnit(
          id: '',
          name: '3º Grupamento de Bombeiros Militar',
          code: '3º GBM',
          address: 'Rua C-140, Jardim América',
          city: 'Goiânia',
          state: 'GO',
          phone: '(62) 3201-6700',
          email: '3gbm@bombeiros.go.gov.br',
          commanderName: 'Comandante 3º GBM',
          commanderRank: 'Major',
          createdAt: DateTime.now(),
        ),
      ];

      // Criar as unidades
      for (final unit in defaultUnits) {
        await createUnit(unit);
      }
    } catch (e) {
      throw Exception('Erro ao criar unidades padrão: $e');
    }
  }
}