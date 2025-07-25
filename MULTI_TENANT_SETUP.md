# Configuração Multi-Tenant - Plataforma Bravo

## Visão Geral

Este documento descreve a implementação da arquitetura multi-tenant na Plataforma Bravo, permitindo que o sistema suporte múltiplas unidades do CBMGO de forma isolada e escalável.

## Arquivos Criados/Modificados

### Novos Modelos
- `lib/core/models/fire_unit.dart` - Modelo para unidades do CBMGO
- Modificado `lib/core/models/user.dart` - Adicionados campos multi-tenant

### Novos Serviços
- `lib/core/services/fire_unit_service.dart` - Gerenciamento de unidades
- Modificado `lib/core/services/auth_service.dart` - Suporte multi-tenant

### Novos Providers
- `lib/core/providers/fire_unit_providers.dart` - Estado das unidades
- Modificado `lib/core/providers/auth_providers.dart` - Métodos multi-tenant

### Novos Widgets
- `lib/core/widgets/unit_selector.dart` - Seletor de unidades
- `lib/core/widgets/migration_setup.dart` - Configuração inicial

### Utilitários
- `lib/core/utils/migration_helper.dart` - Helper para migração

### Modificações na Interface
- Modificado `lib/app/home/views/home_screen.dart` - Integração do seletor
- Modificado `lib/main.dart` - Widget de migração

## Funcionalidades Implementadas

### 1. Modelo de Unidades (FireUnit)
- Representação completa das unidades do CBMGO
- Campos: nome, código, endereço, comandante, etc.
- Suporte a metadados e tipos de unidade

### 2. Usuários Multi-Tenant (AppUser)
- `currentUnitId`: Unidade atual do usuário
- `unitIds`: Lista de unidades que o usuário tem acesso
- `isGlobalAdmin`: Flag para administradores globais
- Métodos para verificação de permissões

### 3. Gerenciamento de Unidades
- Criação e atualização de unidades
- Busca por cidade, código ou ID
- Estatísticas de unidades
- Criação automática das unidades padrão do CBMGO

### 4. Seleção de Unidades
- Widget para seleção da unidade atual
- Exibição de informações da unidade
- Controle de permissões baseado no usuário

### 5. Migração Automática
- Verificação automática da necessidade de migração
- Criação das unidades padrão
- Migração de usuários existentes
- Configuração do primeiro admin como global
- Validação da integridade dos dados

## Como Usar

### Primeira Execução
1. Execute o aplicativo
2. O sistema detectará automaticamente a necessidade de migração
3. Clique em "Configurar Sistema" para executar a migração
4. Aguarde a conclusão do processo

### Seleção de Unidades
1. Na tela inicial, use o seletor de unidades no topo
2. Administradores globais podem acessar todas as unidades
3. Usuários regulares só veem unidades às quais têm acesso

### Gerenciamento de Usuários
- Administradores podem atribuir unidades aos usuários
- Usuários podem alternar entre suas unidades autorizadas
- Administradores globais têm acesso irrestrito

## Estrutura do Firestore

### Coleção: fire_units
```
fire_units/
  {unitId}/
    id: string
    name: string
    code: string
    address: object
    city: string
    state: string
    phone: string
    email: string
    commanderName: string
    commanderRank: string
    unitType: string
    isActive: boolean
    createdAt: timestamp
    updatedAt: timestamp
    metadata: object
```

### Coleção: users (modificada)
```
users/
  {userId}/
    // Campos existentes...
    currentUnitId: string?
    unitIds: array<string>
    isGlobalAdmin: boolean
```

## Benefícios da Implementação

1. **Escalabilidade**: Suporte a múltiplas unidades sem conflitos
2. **Isolamento**: Dados separados por unidade
3. **Flexibilidade**: Usuários podem ter acesso a múltiplas unidades
4. **Segurança**: Controle granular de permissões
5. **Manutenibilidade**: Código organizado e modular

## Próximos Passos

1. **Filtros por Unidade**: Implementar filtros em todas as consultas
2. **Relatórios**: Adaptar relatórios para contexto multi-tenant
3. **Backup**: Estratégias de backup por unidade
4. **Auditoria**: Logs de ações por unidade
5. **Performance**: Otimizações para grandes volumes de dados

## Comandos Úteis

### Executar Migração Manualmente
```dart
import 'package:gestaocbmgo/core/utils/migration_helper.dart';

// Verificar se precisa migrar
final needsMigration = await MigrationHelper.needsMigration();

// Executar migração
if (needsMigration) {
  await MigrationHelper.runFullMigration();
}

// Validar migração
final isValid = await MigrationHelper.validateMigration();
```

### Criar Unidade Programaticamente
```dart
import 'package:gestaocbmgo/core/services/fire_unit_service.dart';

final unit = FireUnit(
  id: 'unique-id',
  name: 'Nome da Unidade',
  code: 'CBM-001',
  // ... outros campos
);

await FireUnitService.createUnit(unit);
```

## Troubleshooting

### Problema: Migração não executa
- Verifique as permissões do Firestore
- Confirme a conexão com o Firebase
- Verifique os logs no console

### Problema: Usuário não vê unidades
- Verifique se o usuário tem `unitIds` configurado
- Confirme se as unidades existem no Firestore
- Verifique se o usuário está autenticado

### Problema: Seletor não aparece
- Verifique se o widget está importado corretamente
- Confirme se os providers estão configurados
- Verifique se há erros no console

## Suporte

Para dúvidas ou problemas, consulte:
1. Este documento
2. Comentários no código
3. Logs do sistema
4. Documentação do Firebase/Firestore