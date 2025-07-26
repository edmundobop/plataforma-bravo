import 'package:flutter/material.dart';
import '../../../core/models/notification.dart';
import '../../../features/checklist_viaturas/utils/app_colors.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.grey[300]! 
              : _getPriorityColor(notification.priority).withValues(alpha: 0.3),
          width: notification.isRead ? 0.5 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead 
                ? Colors.white 
                : _getPriorityColor(notification.priority).withValues(alpha: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da notificação
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone do tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification.priority),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(notification.type),
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Conteúdo principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título e indicador de não lida
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                  fontSize: 16,
                                  color: notification.isRead 
                                      ? Colors.grey[800] 
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(notification.priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Mensagem
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: notification.isRead 
                                ? Colors.grey[600] 
                                : Colors.grey[700],
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Menu de ações
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          onMarkAsRead?.call();
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.done, size: 16),
                              SizedBox(width: 8),
                              Text('Marcar como lida'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Rodapé com informações adicionais
              Row(
                children: [
                  // Chip de prioridade
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(notification.priority).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getPriorityText(notification.priority),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(notification.priority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chip de tipo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeText(notification.type),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Timestamp
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              // URL de ação (se existir)
              if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Toque para ver detalhes',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Notificação'),
        content: const Text('Tem certeza que deseja excluir esta notificação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
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
        return 'CRÍTICA';
      case NotificationPriority.high:
        return 'ALTA';
      case NotificationPriority.medium:
        return 'MÉDIA';
      case NotificationPriority.low:
        return 'BAIXA';
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      // Formato de data para períodos mais longos
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }
}