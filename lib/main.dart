import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/navigation/app_router.dart';
import 'core/widgets/migration_setup.dart';
import 'core/utils/user_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar Firestore (apenas uma vez, antes de qualquer outra operação Firestore)
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  
  print('🚀 MAIN: Iniciando verificação de unidades...');
  
  // Verificar e criar unidades padrão se necessário
  await _ensureDefaultUnits();
  
  print('🚀 MAIN: Verificação de unidades concluída!');
  
  print('👥 MAIN: Iniciando migração de usuários...');
  
  // Migrar usuários existentes
  await UserMigration.migrateExistingUsers();
  
  print('👥 MAIN: Migração de usuários concluída!');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Função para garantir que as unidades padrão existam
Future<void> _ensureDefaultUnits() async {
  try {
    print('🔍 Verificando unidades no Firestore...');
    
    final unitsSnapshot = await FirebaseFirestore.instance
        .collection('fire_units')
        .get();
    
    List<String> unitIds = [];
    
    if (unitsSnapshot.docs.isEmpty) {
      print('⚠️ Nenhuma unidade encontrada. Criando unidades padrão...');
      
      final defaultUnits = [
        {
          'name': 'Comando Geral do CBMGO',
          'code': 'CG-CBMGO',
          'address': 'Rua 1037, nº 230, Setor Pedro Ludovico',
          'city': 'Goiânia',
          'state': 'GO',
          'phone': '(62) 3201-6500',
          'email': 'comando@bombeiros.go.gov.br',
          'commanderName': '',
          'commanderRank': 'Coronel',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': '1º Grupamento de Bombeiros Militar',
          'code': '1º GBM',
          'address': 'Avenida Anhanguera, nº 5195, Setor Coimbra',
          'city': 'Goiânia',
          'state': 'GO',
          'phone': '(62) 3201-6600',
          'email': '1gbm@bombeiros.go.gov.br',
          'commanderName': '',
          'commanderRank': 'Tenente Coronel',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];
      
      final batch = FirebaseFirestore.instance.batch();
      
      for (final unitData in defaultUnits) {
        final docRef = FirebaseFirestore.instance.collection('fire_units').doc();
        batch.set(docRef, unitData);
        unitIds.add(docRef.id);
      }
      
      await batch.commit();
      print('✅ Unidades padrão criadas com sucesso!');
    } else {
      print('✅ Unidades já existem no Firestore');
      unitIds = unitsSnapshot.docs.map((doc) => doc.id).toList();
    }
    
    // Verificar e atualizar usuários sem unidades vinculadas
    await _linkUsersToUnits(unitIds);
    
  } catch (e) {
    print('❌ Erro ao verificar/criar unidades: $e');
  }
}

// Função para vincular usuários às unidades
Future<void> _linkUsersToUnits(List<String> unitIds) async {
  try {
    print('🔗 Verificando usuários sem unidades vinculadas...');
    
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('ℹ️ Nenhum usuário encontrado');
      return;
    }
    
    final batch = FirebaseFirestore.instance.batch();
    int updatedUsers = 0;
    
    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      
      // Verificar se o usuário já tem unidades vinculadas
      final userUnitIds = userData['unitIds'] as List<dynamic>?;
      
      if (userUnitIds == null || userUnitIds.isEmpty) {
        // Vincular usuário a todas as unidades disponíveis
        final updates = {
          'unitIds': unitIds,
          'currentUnitId': unitIds.isNotEmpty ? unitIds.first : null,
          'isGlobalAdmin': userData['role'] == 'admin',
        };
        
        batch.update(userDoc.reference, updates);
        updatedUsers++;
        print('👤 Vinculando usuário ${userData['name'] ?? userDoc.id} às unidades');
      }
    }
    
    if (updatedUsers > 0) {
      await batch.commit();
      print('✅ $updatedUsers usuários vinculados às unidades!');
    } else {
      print('ℹ️ Todos os usuários já estão vinculados às unidades');
    }
    
  } catch (e) {
    print('❌ Erro ao vincular usuários às unidades: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plataforma Bravo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MigrationSetup(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}