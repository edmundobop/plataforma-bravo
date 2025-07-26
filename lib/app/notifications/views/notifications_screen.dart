import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../core/models/notification.dart';
import '../../../features/checklist_viaturas/utils/app_colors.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_filters.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationActions = ref.watch(notificationActionsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Central de Notificações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Botão de filtros
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filtros',
          ),
          // Botão marcar todas como lidas
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'mark_all_read':
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  await notificationActions.markAllAsRead();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Todas as notificações foram marcadas como lidas'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  break;
                case 'clear_filters':
                  notificationActions.clearFilters();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 8),
                    Text('Marcar todas como lidas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text('Limpar filtros'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications),
                  const SizedBox(width: 8),
                  const Text('Todas'),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final notificationsAsync = ref.watch(notificationsStreamProvider);
                      return notificationsAsync.when(
                        data: (notifications) => _buildBadge(notifications.length),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active),
                  const SizedBox(width: 8),
                  const Text('Não Lidas'),
                  const SizedBox(width: 4),
                  unreadCountAsync.when(
                    data: (count) => _buildBadge(count),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtros (se visíveis)
          if (_showFilters)
            Container(
              color: Colors.white,
              child: const NotificationFiltersWidget(),
            ),
          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllNotificationsTab(),
                _buildUnreadNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    if (count == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: AppColors.primaryRed,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    final filteredNotificationsAsync = ref.watch(filteredNotificationsProvider);

    return filteredNotificationsAsync.when(
      data: (notifications) => _buildNotificationsList(notifications, false),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      ),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildUnreadNotificationsTab() {
    final unreadNotificationsAsync = ref.watch(unreadNotificationsStreamProvider);

    return unreadNotificationsAsync.when(
      data: (notifications) => _buildNotificationsList(notifications, true),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      ),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications, bool isUnreadTab) {
    if (notifications.isEmpty) {
      return _buildEmptyState(isUnreadTab);
    }

    return RefreshIndicator(
      color: AppColors.primaryRed,
      onRefresh: () async {
        // O stream já atualiza automaticamente
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onMarkAsRead: () => _markAsRead(notification.id),
            onDelete: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isUnreadTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnreadTab ? Icons.notifications_none : Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isUnreadTab 
                ? 'Nenhuma notificação não lida'
                : 'Nenhuma notificação encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUnreadTab 
                ? 'Todas as suas notificações foram lidas'
                : 'Quando você receber notificações, elas aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar notificações',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Forçar rebuild dos providers
              ref.invalidate(notificationsStreamProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Marcar como lida se não estiver
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navegar para a URL de ação se existir
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      context.go(notification.actionUrl!);
    }
  }

  void _markAsRead(String notificationId) {
    ref.read(notificationActionsProvider).markAsRead(notificationId);
  }

  void _deleteNotification(String notificationId) {
    ref.read(notificationActionsProvider).deleteNotification(notificationId);
  }
}