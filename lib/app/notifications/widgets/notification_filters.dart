import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../features/checklist_viaturas/utils/app_colors.dart';

class NotificationFiltersWidget extends ConsumerWidget {
  const NotificationFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(notificationFiltersProvider);

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Título dos filtros
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              // Botão para limpar filtros
              if (filters.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(notificationFiltersProvider.notifier).clearFilters();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Limpar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filtros de tipo
          Text(
            'Tipo de Notificação',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NotificationType.values.map((type) {
              final isSelected = filters.selectedTypes.contains(type);
              return FilterChip(
                label: Text(
                  _getTypeText(type),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(notificationFiltersProvider.notifier).addTypeFilter(type);
                  } else {
                    ref.read(notificationFiltersProvider.notifier).removeTypeFilter(type);
                  }
                },
                selectedColor: AppColors.primaryRed,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? AppColors.primaryRed : Colors.grey[300]!,
                ),
                avatar: Icon(
                  _getTypeIcon(type),
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros de prioridade
          Text(
            'Prioridade',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NotificationPriority.values.map((priority) {
              final isSelected = filters.selectedPriorities.contains(priority);
              final priorityColor = _getPriorityColor(priority);
              return FilterChip(
                label: Text(
                  _getPriorityText(priority),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : priorityColor,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(notificationFiltersProvider.notifier).addPriorityFilter(priority);
                  } else {
                    ref.read(notificationFiltersProvider.notifier).removePriorityFilter(priority);
                  }
                },
                selectedColor: priorityColor,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: priorityColor,
                  width: isSelected ? 0 : 1,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros de período
          Text(
            'Período',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip(
                  context,
                  ref,
                  'Hoje',
                  () => _setDateFilter(ref, DateTime.now().subtract(const Duration(days: 1))),
                  _isDateFilterActive(filters, 1),
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  context,
                  ref,
                  'Última semana',
                  () => _setDateFilter(ref, DateTime.now().subtract(const Duration(days: 7))),
                  _isDateFilterActive(filters, 7),
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  context,
                  ref,
                  'Último mês',
                  () => _setDateFilter(ref, DateTime.now().subtract(const Duration(days: 30))),
                  _isDateFilterActive(filters, 30),
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  context,
                  ref,
                  'Personalizado',
                  () => _showDateRangePicker(context, ref),
                  filters.startDate != null && filters.endDate != null,
                ),
              ],
            ),
          ),
          
          // Exibir período selecionado
          if (filters.startDate != null || filters.endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 14,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(filters.startDate, filters.endDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        ref.read(notificationFiltersProvider.notifier).clearDateFilter();
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _setDateFilter(WidgetRef ref, DateTime startDate) {
    ref.read(notificationFiltersProvider.notifier).setDateRange(
      startDate,
      DateTime.now(),
    );
  }

  bool _isDateFilterActive(NotificationFilters filters, int days) {
    if (filters.startDate == null || filters.endDate == null) return false;
    
    final expectedStart = DateTime.now().subtract(Duration(days: days));
    final daysDiff = filters.startDate!.difference(expectedStart).inDays.abs();
    
    return daysDiff <= 1; // Tolerância de 1 dia
  }

  void _showDateRangePicker(BuildContext context, WidgetRef ref) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryRed,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(notificationFiltersProvider.notifier).setDateRange(
        picked.start,
        picked.end,
      );
    }
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    
    final startStr = start != null 
        ? '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}'
        : '';
    final endStr = end != null 
        ? '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}'
        : '';
    
    if (start != null && end != null) {
      return '$startStr - $endStr';
    } else if (start != null) {
      return 'A partir de $startStr';
    } else {
      return 'Até $endStr';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.red[700]!;
      case NotificationPriority.high:
        return Colors.orange[700]!;
      case NotificationPriority.medium:
        return Colors.blue[700]!;
      case NotificationPriority.low:
        return Colors.grey[600]!;
    }
  }

  String _getPriorityText(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'Crítica';
      case NotificationPriority.high:
        return 'Alta';
      case NotificationPriority.medium:
        return 'Média';
      case NotificationPriority.low:
        return 'Baixa';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.stockAlert:
        return Icons.inventory_2;
      case NotificationType.stockMovement:
        return Icons.swap_horiz;
      case NotificationType.fleetInspection:
        return Icons.directions_car;
      case NotificationType.fleetMaintenance:
        return Icons.build;
      case NotificationType.userManagement:
        return Icons.person;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.general:
        return Icons.info;
    }
  }

  String _getTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.stockAlert:
        return 'Estoque';
      case NotificationType.stockMovement:
        return 'Movimentação';
      case NotificationType.fleetInspection:
        return 'Frota';
      case NotificationType.fleetMaintenance:
        return 'Manutenção';
      case NotificationType.userManagement:
        return 'Usuários';
      case NotificationType.systemAlert:
        return 'Sistema';
      case NotificationType.general:
        return 'Geral';
    }
  }
}