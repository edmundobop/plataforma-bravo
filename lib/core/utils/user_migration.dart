import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/fire_unit_service.dart';

/// Utilitário para migrar usuários existentes do Firebase Auth para o Firestore
class UserMigration {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migra usuários existentes do Firebase Auth para o Firestore
  static Future<void> migrateExistingUsers() async {
    try {
      print('🔄 Iniciando migração de usuários...');
      
      // IDs dos usuários conhecidos
      final knownUserIds = [
        'wS3ommsJzcZGvt2bfWs1ckW2Xts1', // usuário comum
        'GgscDGdFOZPYZLvuS8opk97pMqu1', // admin
      ];
      
      // Buscar todas as unidades disponíveis
      final unitsSnapshot = await _firestore.collection('fire_units').get();
      final unitIds = unitsSnapshot.docs.map((doc) => doc.id).toList();
      
      print('📋 Encontradas ${unitIds.length} unidades disponíveis');
      
      for (int i = 0; i < knownUserIds.length; i++) {
        final userId = knownUserIds[i];
        final isAdmin = i == 1; // segundo usuário é admin
        
        await _migrateUser(userId, isAdmin, unitIds);
      }
      
      print('✅ Migração de usuários concluída!');
      
    } catch (e) {
      print('❌ Erro durante migração: $e');
      rethrow;
    }
  }
  
  /// Migra um usuário específico
  static Future<void> _migrateUser(String userId, bool isAdmin, List<String> unitIds) async {
    try {
      // Verificar se o usuário já existe no Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        print('👤 Usuário $userId já existe no Firestore, atualizando...');
        
        // Atualizar dados existentes
        await _firestore.collection('users').doc(userId).update({
          'unitIds': unitIds,
          'currentUnitId': unitIds.isNotEmpty ? unitIds.first : null,
          'isGlobalAdmin': isAdmin,
          'role': isAdmin ? 'admin' : 'user',
          'updatedAt': Timestamp.now(),
        });
        
        print('✅ Usuário $userId atualizado com ${unitIds.length} unidades');
        return;
      }
      
      // Criar novo documento do usuário
      final userData = {
        'id': userId,
        'email': isAdmin ? 'admin@bombeiros.go.gov.br' : 'user@bombeiros.go.gov.br',
        'name': isAdmin ? 'Administrador' : 'Usuário Comum',
        'role': isAdmin ? 'admin' : 'user',
        'department': 'CBMGO',
        'phone': '',
        'isActive': true,
        'unitIds': unitIds,
        'currentUnitId': unitIds.isNotEmpty ? unitIds.first : null,
        'isGlobalAdmin': isAdmin,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };
      
      await _firestore.collection('users').doc(userId).set(userData);
      
      print('✅ Usuário $userId criado no Firestore com ${unitIds.length} unidades');
      
    } catch (e) {
      print('❌ Erro ao migrar usuário $userId: $e');
      rethrow;
    }
  }
  
  /// Força a vinculação de unidades para todos os usuários
  static Future<void> forceUserUnitsLink() async {
    try {
      print('🔗 Forçando vinculação de unidades para todos os usuários...');
      
      // Buscar todas as unidades
      final unitsSnapshot = await _firestore.collection('fire_units').get();
      final unitIds = unitsSnapshot.docs.map((doc) => doc.id).toList();
      
      // Buscar todos os usuários
      final usersSnapshot = await _firestore.collection('users').get();
      
      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final currentUnitIds = List<String>.from(userData['unitIds'] ?? []);
        
        if (currentUnitIds.isEmpty) {
          await _firestore.collection('users').doc(userDoc.id).update({
            'unitIds': unitIds,
            'currentUnitId': unitIds.isNotEmpty ? unitIds.first : null,
            'updatedAt': Timestamp.now(),
          });
          
          print('🔗 Usuário ${userDoc.id} vinculado a ${unitIds.length} unidades');
        } else {
          print('✅ Usuário ${userDoc.id} já possui ${currentUnitIds.length} unidades');
        }
      }
      
      print('✅ Vinculação de unidades concluída!');
      
    } catch (e) {
      print('❌ Erro ao vincular unidades: $e');
      rethrow;
    }
  }
}