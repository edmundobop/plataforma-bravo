import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fire_unit.dart';
import '../services/fire_unit_service.dart';

/// Helper para migração e configuração inicial do sistema multi-tenant
class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Executa a migração completa do sistema
  static Future<void> runFullMigration() async {
    try {
      print('Iniciando migração do sistema...');
      
      // 1. Criar unidades padrão do CBMGO
      await _createDefaultUnits();
      print('✓ Unidades padrão criadas');
      
      // 2. Migrar usuários existentes
      await _migrateExistingUsers();
      print('✓ Usuários migrados');
      
      // 3. Configurar admin global inicial
      await _setupInitialGlobalAdmin();
      print('✓ Admin global configurado');
      
      print('Migração concluída com sucesso!');
    } catch (e) {
      print('Erro durante a migração: $e');
      rethrow;
    }
  }

  /// Cria as unidades padrão do CBMGO
  static Future<void> _createDefaultUnits() async {
    final units = await FireUnitService.createDefaultCBMGOUnits();
    print('Criadas ${units.length} unidades do CBMGO');
  }

  /// Migra usuários existentes para o novo modelo multi-tenant
  static Future<void> _migrateExistingUsers() async {
    final usersSnapshot = await _firestore.collection('users').get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('Nenhum usuário encontrado para migração');
      return;
    }

    final batch = _firestore.batch();
    int migratedCount = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      
      // Verificar se já foi migrado
      if (data.containsKey('unitIds')) {
        continue;
      }

      // Adicionar campos multi-tenant
      final updates = <String, dynamic>{
        'unitIds': <String>[], // Lista vazia inicialmente
        'currentUnitId': null,
        'isGlobalAdmin': false,
      };

      batch.update(doc.reference, updates);
      migratedCount++;
    }

    if (migratedCount > 0) {
      await batch.commit();
      print('Migrados $migratedCount usuários');
    } else {
      print('Todos os usuários já foram migrados');
    }
  }

  /// Configura o primeiro admin como admin global
  static Future<void> _setupInitialGlobalAdmin() async {
    final adminQuery = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (adminQuery.docs.isEmpty) {
      print('Nenhum admin encontrado para configurar como global');
      return;
    }

    final adminDoc = adminQuery.docs.first;
    await adminDoc.reference.update({
      'isGlobalAdmin': true,
    });

    print('Admin global configurado: ${adminDoc.data()['name']}');
  }

  /// Verifica se o sistema precisa de migração
  static Future<bool> needsMigration() async {
    try {
      // Verificar se existem unidades
      final unitsSnapshot = await _firestore
          .collection('fire_units')
          .limit(1)
          .get();
      
      if (unitsSnapshot.docs.isEmpty) {
        return true;
      }

      // Verificar se existem usuários não migrados
      final usersSnapshot = await _firestore
          .collection('users')
          .where('unitIds', isNull: true)
          .limit(1)
          .get();
      
      return usersSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar necessidade de migração: $e');
      return false;
    }
  }

  /// Executa migração apenas se necessário
  static Future<void> runMigrationIfNeeded() async {
    if (await needsMigration()) {
      await runFullMigration();
    } else {
      print('Sistema já está migrado');
    }
  }

  /// Limpa dados de teste (apenas para desenvolvimento)
  static Future<void> cleanTestData() async {
    final batch = _firestore.batch();
    
    // Limpar unidades de teste
    final unitsSnapshot = await _firestore
        .collection('fire_units')
        .where('metadata.isTest', isEqualTo: true)
        .get();
    
    for (final doc in unitsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('Dados de teste removidos');
  }

  /// Valida a integridade dos dados após migração
  static Future<bool> validateMigration() async {
    try {
      // Verificar se todas as unidades têm IDs válidos
      final unitsSnapshot = await _firestore.collection('fire_units').get();
      for (final doc in unitsSnapshot.docs) {
        if (doc.id.isEmpty || !doc.data().containsKey('name')) {
          print('Unidade inválida encontrada: ${doc.id}');
          return false;
        }
      }

      // Verificar se todos os usuários têm campos multi-tenant
      final usersSnapshot = await _firestore.collection('users').get();
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('unitIds') || 
            !data.containsKey('isGlobalAdmin')) {
          print('Usuário não migrado encontrado: ${doc.id}');
          return false;
        }
      }

      print('Validação da migração: ✓ Sucesso');
      return true;
    } catch (e) {
      print('Erro na validação da migração: $e');
      return false;
    }
  }
}