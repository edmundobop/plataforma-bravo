import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fire_unit.dart';
import '../providers/fire_unit_providers.dart';

class UnitSelector extends ConsumerWidget {
  const UnitSelector({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  final bool showLabel;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSwitchUnits = ref.watch(canSwitchUnitsProvider);
    final currentUnit = ref.watch(currentUnitProvider);
    final userUnitsAsync = ref.watch(userUnitsProvider);
    final unitSelectionAsync = ref.watch(unitSelectionProvider);

    // Sempre mostrar as unidades, mesmo se o usuário não pode trocar
    // Isso permite visualizar as unidades disponíveis

    return userUnitsAsync.when(
      data: (units) {
        print('🔍 UnitSelector: Recebidas ${units.length} unidades');
        for (var unit in units) {
          print('📋 UnitSelector: Unidade disponível: ${unit.code} - ${unit.name}');
        }
        
        if (units.isEmpty) {
          print('⚠️ UnitSelector: Lista de unidades vazia, mostrando mensagem de erro');
          // Se não há unidades, mostrar mensagem de erro com botão para recarregar
          return compact
              ? _buildCompactNoUnits(context, ref)
              : _buildFullNoUnits(context, ref, showLabel);
        }

        // Sempre permitir seleção se há múltiplas unidades
        bool allowSelection = units.length > 1;
        
        if (compact) {
          return _buildCompactSelector(context, ref, currentUnit, units, unitSelectionAsync, allowSelection);
        }

        return _buildFullSelector(context, ref, currentUnit, units, unitSelectionAsync, showLabel, allowSelection);
      },
      loading: () => compact
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const CircularProgressIndicator(),
      error: (error, _) {
        // Em caso de erro, mostrar a unidade atual se disponível
        // ou uma mensagem mais amigável
        if (currentUnit != null) {
          return compact
              ? _buildCompactDisplay(currentUnit)
              : _buildFullDisplay(context, currentUnit, showLabel);
        }
        
        return compact
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Erro',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Erro ao carregar unidades',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Verifique sua conexão e tente novamente',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildCompactDisplay(FireUnit? currentUnit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_city, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Text(
            currentUnit?.code ?? 'N/A',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDisplay(BuildContext context, FireUnit? currentUnit, bool showLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            'Unidade Atual',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (showLabel) const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.location_city, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUnit?.code ?? 'Nenhuma unidade',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (currentUnit != null)
                      Text(
                        currentUnit.name,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    WidgetRef ref,
    FireUnit? currentUnit,
    List<FireUnit> units,
    AsyncValue<FireUnit?> unitSelectionAsync,
    bool allowSelection,
  ) {
    // Se há apenas uma unidade, mostrar apenas como display
    if (!allowSelection) {
      return _buildCompactDisplay(currentUnit);
    }
    
    return PopupMenuButton<FireUnit>(
      enabled: !unitSelectionAsync.isLoading,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unitSelectionAsync.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.location_city, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 4),
            Text(
              currentUnit?.code ?? 'Selecionar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.blue.shade700),
          ],
        ),
      ),
      itemBuilder: (context) => units.map((unit) {
        final isSelected = currentUnit?.id == unit.id;
        return PopupMenuItem<FireUnit>(
          value: unit,
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check, size: 16, color: Colors.blue.shade700)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unit.code,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      unit.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (unit) {
        ref.read(unitSelectionProvider.notifier).selectUnit(unit);
      },
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    WidgetRef ref,
    FireUnit? currentUnit,
    List<FireUnit> units,
    AsyncValue<FireUnit?> unitSelectionAsync,
    bool showLabel,
    bool allowSelection,
  ) {
    // Se há apenas uma unidade, mostrar apenas as informações
    if (!allowSelection) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Text(
              'Unidades Disponíveis',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (showLabel) const SizedBox(height: 8),
          ...units.map((unit) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unit.id == currentUnit?.id ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: unit.id == currentUnit?.id ? Colors.blue.shade200 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: unit.id == currentUnit?.id ? Colors.blue.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.code,
                        style: TextStyle(
                          fontWeight: unit.id == currentUnit?.id ? FontWeight.bold : FontWeight.w500,
                          color: unit.id == currentUnit?.id ? Colors.blue.shade700 : Colors.black87,
                        ),
                      ),
                      Text(
                        unit.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unit.id == currentUnit?.id)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
              ],
            ),
          )).toList(),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            'Selecionar Unidade',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (showLabel) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FireUnit>(
              value: currentUnit,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Selecione uma unidade'),
              ),
              items: units.map((unit) {
                return DropdownMenuItem<FireUnit>(
                  value: unit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_city, size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                unit.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                unit.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: unitSelectionAsync.isLoading
                  ? null
                  : (unit) {
                      if (unit != null) {
                        ref.read(unitSelectionProvider.notifier).selectUnit(unit);
                      }
                    },
            ),
          ),
        ),
        if (unitSelectionAsync.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Erro ao selecionar unidade: ${unitSelectionAsync.error}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // Widget compacto quando não há unidades
  Widget _buildCompactNoUnits(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            'Sem unidades',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              ref.invalidate(userUnitsProvider);
              ref.read(unitSelectionProvider.notifier).refreshUnits();
            },
            child: Icon(
              Icons.refresh,
              size: 16,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Widget completo quando não há unidades
  Widget _buildFullNoUnits(BuildContext context, WidgetRef ref, bool showLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            'Unidades Disponíveis',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (showLabel) const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nenhuma unidade disponível',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Suas unidades podem estar sendo carregadas. Tente recarregar.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(userUnitsProvider);
                  ref.read(unitSelectionProvider.notifier).refreshUnits();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Recarregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade700,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget para mostrar informações da unidade atual
class CurrentUnitInfo extends ConsumerWidget {
  const CurrentUnitInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUnit = ref.watch(currentUnitProvider);

    if (currentUnit == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Nenhuma unidade selecionada'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  currentUnit.code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentUnit.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentUnit.city}, ${currentUnit.state}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            if (currentUnit.commanderName.isNotEmpty) ...[
               const SizedBox(height: 8),
               Text(
                 'Comandante: ${currentUnit.commanderRank} ${currentUnit.commanderName}',
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.grey.shade600,
                 ),
               ),
             ],
          ],
        ),
      ),
    );
  }
}