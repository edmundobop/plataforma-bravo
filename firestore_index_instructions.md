# Instruções para Configurar Índices do Firestore

## Problema do Índice Composto

Se você ainda encontrar o erro relacionado ao índice composto do Firestore para movimentações de estoque, siga estas instruções:

### Erro Típico:
```
[cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/plataforma-bravo-7e970/firestore/indexes?create_composite=Cl5wcm9qZWN0cy9wbGF0YWZvcm1hLWJyYXZvLTdlOTcwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9zdG9ja19tb3ZlbWVudHMvaW5kZXhlcy9fABoKCgZ1c2VySWQQARoMCghjcmVhdGVkQXQQAhoMCghfX25hbWVfXxAB
```

### Solução:

1. **Acesse o Console do Firebase:**
   - Vá para [Firebase Console](https://console.firebase.google.com)
   - Selecione seu projeto `plataforma-bravo`

2. **Navegue para Firestore:**
   - No menu lateral, clique em "Firestore Database"
   - Vá para a aba "Indexes"

3. **Crie o Índice Composto:**
   - Clique em "Create Index"
   - Configure o índice com os seguintes campos:
     - **Collection ID:** `stock_movements`
     - **Fields:**
       - `userId` (Ascending)
       - `createdAt` (Descending)

4. **Configuração Alternativa (Recomendada):**
   - Como implementamos uma solução que evita o índice composto, você pode usar a abordagem atual que filtra no cliente
   - Isso evita a necessidade de criar índices adicionais no Firestore

### Configuração Atual (Sem Índice Composto):

O código atual foi modificado para:
- Administradores: Buscar todas as movimentações ordenadas por data
- Usuários comuns: Buscar movimentações por `userId` e ordenar no cliente

Esta abordagem evita a necessidade de índices compostos e funciona bem para volumes moderados de dados.

### Monitoramento:

Se você notar lentidão nas consultas, considere:
1. Criar o índice composto conforme instruções acima
2. Implementar paginação para grandes volumes de dados
3. Usar cache local para melhorar a performance