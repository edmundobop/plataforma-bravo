import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fire_unit.dart';

class AddTestUnits {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addUnitsIfNeeded() async {
    try {
      print('🔍 Verificando unidades existentes...');
      
      // Verificar quantas unidades ativas existem
      final activeUnitsSnapshot = await _firestore
          .collection('fire_units')
          .where('isActive', isEqualTo: true)
          .get();
      
      print('📊 Unidades ativas encontradas: ${activeUnitsSnapshot.docs.length}');
      
      // Se temos menos de 4 unidades, adicionar mais
      if (activeUnitsSnapshot.docs.length < 4) {
        print('➕ Adicionando unidades de teste...');
        
        final testUnits = [
          {
            'name': '1º Grupamento de Bombeiros Militar',
            'code': '1º GBM',
            'address': 'Rua 84, nº 399, Setor Sul',
            'city': 'Goiânia',
            'state': 'GO',
            'phone': '(62) 3201-6500',
            'email': '1gbm@bombeiros.go.gov.br',
            'commanderName': 'Comandante 1º GBM',
            'commanderRank': 'Tenente Coronel',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          },
          {
            'name': '2º Grupamento de Bombeiros Militar',
            'code': '2º GBM',
            'address': 'Avenida Anhanguera, nº 5195, Setor Aeroviário',
            'city': 'Goiânia',
            'state': 'GO',
            'phone': '(62) 3201-6600',
            'email': '2gbm@bombeiros.go.gov.br',
            'commanderName': 'Comandante 2º GBM',
            'commanderRank': 'Tenente Coronel',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          },
          {
            'name': '3º Grupamento de Bombeiros Militar',
            'code': '3º GBM',
            'address': 'Rua C-140, Jardim América',
            'city': 'Goiânia',
            'state': 'GO',
            'phone': '(62) 3201-6700',
            'email': '3gbm@bombeiros.go.gov.br',
            'commanderName': 'Comandante 3º GBM',
            'commanderRank': 'Tenente Coronel',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          },
        ];
        
        int addedCount = 0;
        
        for (final unitData in testUnits) {
          // Verificar se já existe uma unidade com o mesmo código
          final existingSnapshot = await _firestore
              .collection('fire_units')
              .where('code', isEqualTo: unitData['code'])
              .get();
          
          if (existingSnapshot.docs.isEmpty) {
            await _firestore.collection('fire_units').add(unitData);
            print('✅ Unidade ${unitData['code']} adicionada');
            addedCount++;
          } else {
            print('ℹ️ Unidade ${unitData['code']} já existe');
          }
        }
        
        print('🎉 $addedCount novas unidades adicionadas!');
        
        // Verificar resultado final
        final finalSnapshot = await _firestore
            .collection('fire_units')
            .where('isActive', isEqualTo: true)
            .get();
        
        print('📊 Total de unidades ativas após adição: ${finalSnapshot.docs.length}');
        
      } else {
        print('✅ Sistema já possui ${activeUnitsSnapshot.docs.length} unidades ativas');
      }
      
    } catch (e) {
      print('❌ Erro ao adicionar unidades: $e');
    }
  }
}