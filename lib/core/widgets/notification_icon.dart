import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_providers.dart';
import '../models/notification.dart';

class NotificationIcon extends ConsumerWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return unreadCountAsync.when(
      data: (count) => _buildIcon(context, count),
      loading: () => _buildIcon(context, 0),
      error: (_, __) => _buildIcon(context, 0),
    );
  }

  Widget _buildIcon(BuildContext context, int count) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            size: 24,
          ),
          onPressed: () {
            context.go('/notifications');
          },
          tooltip: 'Notificações',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getCounterColor(count),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _formatCount(count),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Color _getCounterColor(int count) {
    if (count >= 10) {
      return Colors.red; // Muitas notificações
    } else if (count >= 5) {
      return Colors.orange; // Algumas notificações
    } else {
      return Colors.blue; // Poucas notificações
    }
  }

  String _formatCount(int count) {
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }
}

// Widget alternativo para dropdown de notificações rápidas
class NotificationDropdown extends ConsumerStatefulWidget {
  const NotificationDropdown({super.key});

  @override
  ConsumerState<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends ConsumerState<NotificationDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    
    const dropdownWidth = 300.0;
    const dropdownMaxHeight = 400.0;
    const padding = 16.0;
    
    // Calcular posição horizontal
    // Primeiro, tentar alinhar à direita do ícone
    double left = offset.dx - dropdownWidth + size.width;
    
    // Se extrapolaria a direita da tela, alinhar à esquerda do ícone
    if (left + dropdownWidth > screenSize.width - padding) {
      left = offset.dx - dropdownWidth;
    }
    
    // Se ainda extrapolaria a esquerda, forçar dentro da tela
    if (left < padding) {
      left = padding;
    }
    
    // Garantir que nunca extrapole a direita
    if (left + dropdownWidth > screenSize.width - padding) {
      left = screenSize.width - dropdownWidth - padding;
    }
    
    // Calcular posição vertical
    double top = offset.dy + size.height + 8;
    
    // Ajustar se estiver muito embaixo
    if (top + dropdownMaxHeight > screenSize.height - padding) {
      top = offset.dy - dropdownMaxHeight - 8;
      // Se ainda não couber em cima, posicionar no meio da tela
      if (top < padding) {
        top = (screenSize.height - dropdownMaxHeight) / 2;
      }
    }

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Detector de clique fora para fechar
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dropdown de notificações
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: dropdownWidth,
                constraints: BoxConstraints(
                  maxHeight: dropdownMaxHeight,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: _buildDropdownContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContent() {
    final unreadNotificationsAsync = ref.watch(unreadNotificationsStreamProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cabeçalho
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notificações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  _removeOverlay();
                  context.go('/notifications');
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
        ),
        // Lista de notificações
        Flexible(
          child: unreadNotificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notifications.take(5).length, // Mostrar apenas 5
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(notification);
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar notificações',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(notification) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: _getPriorityColor(notification.priority),
        child: Icon(
          _getTypeIcon(notification.type),
          size: 16,
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.message,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(notification.createdAt),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        _removeOverlay();
        // Marcar como lida
        ref.read(notificationActionsProvider).markAsRead(notification.id);
        // Navegar se houver URL
        if (notification.actionUrl != null) {
          context.go(notification.actionUrl!);
        }
      },
    );
  }

  Color _getPriorityColor(priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.red[700]!;
      case NotificationPriority.high:
        return Colors.orange[700]!;
      case NotificationPriority.medium:
        return Colors.blue[700]!;
      case NotificationPriority.low:
        return Colors.grey[600]!;
      default:
        return Colors.blue[700]!;
    }
  }

  IconData _getTypeIcon(type) {
    switch (type) {
      case NotificationType.stockAlert:
        return Icons.inventory_2;
      case NotificationType.stockMovement:
        return Icons.swap_horiz;
      case NotificationType.fleetInspection:
        return Icons.directions_car;
      case NotificationType.userManagement:
        return Icons.person;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.general:
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: unreadCountAsync.when(
        data: (count) => _buildDropdownIcon(context, count),
        loading: () => _buildDropdownIcon(context, 0),
        error: (_, __) => _buildDropdownIcon(context, 0),
      ),
    );
  }

  Widget _buildDropdownIcon(BuildContext context, int count) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            _isOpen ? Icons.notifications : Icons.notifications_outlined,
            size: 24,
          ),
          onPressed: _toggleDropdown,
          tooltip: 'Notificações',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getCounterColor(count),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _formatCount(count),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Color _getCounterColor(int count) {
    if (count >= 10) {
      return Colors.red;
    } else if (count >= 5) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  String _formatCount(int count) {
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }
}