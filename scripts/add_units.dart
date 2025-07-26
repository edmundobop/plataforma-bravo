// Script simples para adicionar unidades via Firestore
// Execute este código no Firebase Console ou use um script Node.js

/*
Const units = [
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

// Para adicionar no Firebase Console:
// 1. Acesse o Firebase Console
// 2. Vá para Firestore Database
// 3. Acesse a coleção 'fire_units'
// 4. Adicione cada documento manualmente ou use o script abaixo no console do navegador:

units.forEach(async (unit, index) => {
  try {
    await firebase.firestore().collection('fire_units').add(unit);
    console.log(`✅ Unidade ${unit.code} adicionada com sucesso!`);
  } catch (error) {
    console.error(`❌ Erro ao adicionar unidade ${unit.code}:`, error);
  }
});

*/