// Script para ativar unidades existentes e adicionar novas no Firebase Console
// Execute este código no console do navegador no Firebase Console

// Primeiro, vamos ativar todas as unidades existentes
const activateExistingUnits = async () => {
  console.log('🔍 Buscando unidades existentes...');
  
  const unitsSnapshot = await firebase.firestore().collection('fire_units').get();
  console.log(`📊 Encontradas ${unitsSnapshot.docs.length} unidades no total`);
  
  let activatedCount = 0;
  
  for (const doc of unitsSnapshot.docs) {
    const data = doc.data();
    console.log(`📋 Unidade: ${data.code} - ${data.name} (ativa: ${data.isActive})`);
    
    if (!data.isActive) {
      try {
        await doc.ref.update({
          isActive: true,
          updatedAt: new Date()
        });
        console.log(`✅ Unidade ${data.code} ativada com sucesso!`);
        activatedCount++;
      } catch (error) {
        console.error(`❌ Erro ao ativar unidade ${data.code}:`, error);
      }
    } else {
      console.log(`ℹ️ Unidade ${data.code} já está ativa`);
    }
  }
  
  console.log(`🎉 ${activatedCount} unidades foram ativadas!`);
  return unitsSnapshot.docs.length;
};

// Unidades adicionais para adicionar se necessário
const additionalUnits = [
  {
    name: '1º Grupamento de Bombeiros Militar',
    code: '1º GBM',
    address: 'Rua 84, nº 399, Setor Sul',
    city: 'Goiânia',
    state: 'GO',
    phone: '(62) 3201-6500',
    email: '1gbm@bombeiros.go.gov.br',
    commanderName: 'Comandante 1º GBM',
    commanderRank: 'Tenente Coronel',
    isActive: true,
    createdAt: new Date()
  },
  {
    name: '2º Grupamento de Bombeiros Militar',
    code: '2º GBM',
    address: 'Avenida Anhanguera, nº 5195, Setor Aeroviário',
    city: 'Goiânia',
    state: 'GO',
    phone: '(62) 3201-6600',
    email: '2gbm@bombeiros.go.gov.br',
    commanderName: 'Comandante 2º GBM',
    commanderRank: 'Tenente Coronel',
    isActive: true,
    createdAt: new Date()
  },
  {
    name: '3º Grupamento de Bombeiros Militar',
    code: '3º GBM',
    address: 'Rua C-140, Jardim América',
    city: 'Goiânia',
    state: 'GO',
    phone: '(62) 3201-6700',
    email: '3gbm@bombeiros.go.gov.br',
    commanderName: 'Comandante 3º GBM',
    commanderRank: 'Tenente Coronel',
    isActive: true,
    createdAt: new Date()
  },
  {
    name: '4º Grupamento de Bombeiros Militar',
    code: '4º GBM',
    address: 'Avenida Perimetral Norte, nº 8303, Jardim Petrópolis',
    city: 'Goiânia',
    state: 'GO',
    phone: '(62) 3201-6800',
    email: '4gbm@bombeiros.go.gov.br',
    commanderName: 'Comandante 4º GBM',
    commanderRank: 'Major',
    isActive: true,
    createdAt: new Date()
  },
  {
    name: '5º Grupamento de Bombeiros Militar',
    code: '5º GBM',
    address: 'Avenida Brasil Norte, nº 1500, Centro',
    city: 'Anápolis',
    state: 'GO',
    phone: '(62) 3201-6900',
    email: '5gbm@bombeiros.go.gov.br',
    commanderName: 'Comandante 5º GBM',
    commanderRank: 'Major',
    isActive: true,
    createdAt: new Date()
  }
];

// Adicionar unidades que não existem
const addMissingUnits = async () => {
  console.log('🔍 Verificando unidades que precisam ser adicionadas...');
  
  let addedCount = 0;
  
  for (const unit of additionalUnits) {
    try {
      // Verificar se já existe uma unidade com o mesmo código
      const existing = await firebase.firestore()
        .collection('fire_units')
        .where('code', '==', unit.code)
        .get();
      
      if (existing.docs.length === 0) {
        await firebase.firestore().collection('fire_units').add(unit);
        console.log(`✅ Unidade ${unit.code} adicionada com sucesso!`);
        addedCount++;
      } else {
        console.log(`ℹ️ Unidade ${unit.code} já existe`);
      }
    } catch (error) {
      console.error(`❌ Erro ao adicionar unidade ${unit.code}:`, error);
    }
  }
  
  console.log(`🎉 ${addedCount} novas unidades foram adicionadas!`);
};

// Função principal
const setupUnits = async () => {
  console.log('🚀 Iniciando configuração das unidades...');
  
  try {
    // Primeiro ativar unidades existentes
    const existingCount = await activateExistingUnits();
    
    // Se temos menos de 5 unidades, adicionar as que faltam
    if (existingCount < 5) {
      console.log('📝 Adicionando unidades que faltam...');
      await addMissingUnits();
    }
    
    // Verificar resultado final
    console.log('\n📊 Verificando resultado final...');
    const finalSnapshot = await firebase.firestore()
      .collection('fire_units')
      .where('isActive', '==', true)
      .get();
    
    console.log(`🎯 Total de unidades ativas: ${finalSnapshot.docs.length}`);
    
    finalSnapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`   ✅ ${data.code}: ${data.name}`);
    });
    
    console.log('\n🎉 Configuração concluída! Recarregue a aplicação para ver as mudanças.');
    
  } catch (error) {
    console.error('❌ Erro durante a configuração:', error);
  }
};

// Executar a configuração
setupUnits();

// Instruções de uso:
console.log(`
📋 INSTRUÇÕES:
1. Abra o Firebase Console
2. Vá para Firestore Database
3. Abra o console do navegador (F12)
4. Cole e execute este código
5. Aguarde a conclusão
6. Recarregue a aplicação Flutter`);