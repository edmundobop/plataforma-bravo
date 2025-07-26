import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import 'auth_providers.dart';
import 'fire_unit_providers.dart';

// Provider para o stream de notificações da unidade atual
final notificationsStreamProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final selectedUnit = ref.watch(currentUnitIdProvider);

  return userAsync.when(
    data: (user) {
      if (user == null || selectedUnit == null) {
        return Stream.value([]);
      }
      return NotificationService.getNotificationsForUser(
         user.id,
         selectedUnit,
         limit: 50,
       );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Provider para notificações não lidas
final unreadNotificationsStreamProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final selectedUnit = ref.watch(currentUnitIdProvider);

  return userAsync.when(
    data: (user) {
      if (user == null || selectedUnit == null) {
        return Stream.value([]);
      }
      return NotificationService.getNotificationsForUser(
        user.id,
        selectedUnit,
        limit: 50,
        onlyUnread: true,
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Provider para contagem de notificações não lidas
final unreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final selectedUnit = ref.watch(currentUnitIdProvider);

  return userAsync.when(
    data: (user) async* {
      if (user == null || selectedUnit == null) {
        yield 0;
        return;
      }
      // Escutar mudanças nas notificações não lidas e contar
      await for (final notifications in NotificationService.getNotificationsForUser(
        user.id,
        selectedUnit,
        onlyUnread: true,
      )) {
        yield notifications.length;
      }
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// Provider para filtros de notificação
final notificationFiltersProvider = StateNotifierProvider.autoDispose<NotificationFiltersNotifier, NotificationFilters>((ref) {
  return NotificationFiltersNotifier();
});

// StateNotifier para gerenciar filtros de notificação
class NotificationFiltersNotifier extends StateNotifier<NotificationFilters> {
  NotificationFiltersNotifier() : super(NotificationFilters());

  void addTypeFilter(NotificationType type) {
    final newTypes = Set<NotificationType>.from(state.selectedTypes)..add(type);
    state = state.copyWith(selectedTypes: newTypes);
  }

  void removeTypeFilter(NotificationType type) {
    final newTypes = Set<NotificationType>.from(state.selectedTypes)..remove(type);
    state = state.copyWith(selectedTypes: newTypes);
  }

  void addPriorityFilter(NotificationPriority priority) {
    final newPriorities = Set<NotificationPriority>.from(state.selectedPriorities)..add(priority);
    state = state.copyWith(selectedPriorities: newPriorities);
  }

  void removePriorityFilter(NotificationPriority priority) {
    final newPriorities = Set<NotificationPriority>.from(state.selectedPriorities)..remove(priority);
    state = state.copyWith(selectedPriorities: newPriorities);
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void clearDateFilter() {
    state = state.copyWith(startDate: null, endDate: null);
  }

  void clearFilters() {
    state = NotificationFilters();
  }

  void toggleUnreadOnly() {
    state = state.copyWith(showOnlyUnread: !state.showOnlyUnread);
  }
}

// Provider para notificações filtradas
final filteredNotificationsProvider = Provider.autoDispose<AsyncValue<List<AppNotification>>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  final filters = ref.watch(notificationFiltersProvider);

  return notificationsAsync.when(
    data: (notifications) {
      var filtered = notifications;

      // Filtrar por tipo
      if (filters.type != null) {
        filtered = filtered.where((n) => n.type == filters.type).toList();
      }

      // Filtrar por prioridade
      if (filters.priority != null) {
        filtered = filtered.where((n) => n.priority == filters.priority).toList();
      }

      // Filtrar por status de leitura
      if (filters.showOnlyUnread) {
        filtered = filtered.where((n) => !n.isRead).toList();
      }

      // Filtrar por módulo
      if (filters.moduleId != null && filters.moduleId!.isNotEmpty) {
        filtered = filtered.where((n) => n.moduleId == filters.moduleId).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider para ações de notificação
final notificationActionsProvider = Provider.autoDispose<NotificationActions>((ref) {
  return NotificationActions(ref);
});

// Classe para filtros de notificação
class NotificationFilters {
  final NotificationType? type;
  final NotificationPriority? priority;
  final bool showOnlyUnread;
  final String? moduleId;
  final Set<NotificationType> selectedTypes;
  final Set<NotificationPriority> selectedPriorities;
  final DateTime? startDate;
  final DateTime? endDate;

  NotificationFilters({
    this.type,
    this.priority,
    this.showOnlyUnread = false,
    this.moduleId,
    this.selectedTypes = const {},
    this.selectedPriorities = const {},
    this.startDate,
    this.endDate,
  });

  NotificationFilters copyWith({
    NotificationType? type,
    NotificationPriority? priority,
    bool? showOnlyUnread,
    String? moduleId,
    Set<NotificationType>? selectedTypes,
    Set<NotificationPriority>? selectedPriorities,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return NotificationFilters(
      type: type ?? this.type,
      priority: priority ?? this.priority,
      showOnlyUnread: showOnlyUnread ?? this.showOnlyUnread,
      moduleId: moduleId ?? this.moduleId,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  // Verificar se há filtros ativos
  bool get hasActiveFilters {
    return type != null ||
           priority != null ||
           showOnlyUnread ||
           (moduleId != null && moduleId!.isNotEmpty) ||
           selectedTypes.isNotEmpty ||
           selectedPriorities.isNotEmpty ||
           startDate != null ||
           endDate != null;
  }

  // Método para limpar filtros
  NotificationFilters clear() {
    return NotificationFilters();
  }
}

// Classe para ações de notificação
class NotificationActions {
  final Ref ref;

  NotificationActions(this.ref);

  // Marcar notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
    } catch (e) {
      // Log do erro ou mostrar snackbar
      // Erro ao marcar notificação como lida
    }
  }

  // Marcar múltiplas notificações como lidas
  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    try {
      await NotificationService.markMultipleAsRead(notificationIds);
    } catch (e) {
      // Erro ao marcar notificações como lidas
    }
  }

  // Marcar todas as notificações como lidas
  Future<void> markAllAsRead() async {
    try {
      final selectedUnit = ref.read(currentUnitIdProvider);
      if (selectedUnit != null) {
        await NotificationService.markAllAsReadForUnit(selectedUnit);
      }
    } catch (e) {
      // Erro ao marcar todas as notificações como lidas
    }
  }

  // Deletar notificação
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
    } catch (e) {
      // Erro ao deletar notificação
    }
  }

  // Criar notificação de estoque baixo
  Future<void> createStockAlert({
    required String productName,
    required int currentStock,
    required int minStock,
    String? productId,
  }) async {
    try {
      final selectedUnit = ref.read(currentUnitIdProvider);
      if (selectedUnit != null) {
        await NotificationService.createStockAlert(
          productName: productName,
          currentStock: currentStock,
          minStock: minStock,
          unitId: selectedUnit,
          productId: productId,
        );
      }
    } catch (e) {
      // Erro ao criar alerta de estoque
    }
  }

  // Criar notificação de movimentação de estoque
  Future<void> createStockMovement({
    required String productName,
    required String movementType,
    required int quantity,
    String? movementId,
  }) async {
    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      final selectedUnit = ref.read(currentUnitIdProvider);
      
      if (user != null && selectedUnit != null) {
        await NotificationService.createStockMovement(
          productName: productName,
          movementType: movementType,
          quantity: quantity,
          unitId: selectedUnit,
          userId: user.id,
          movementId: movementId,
        );
      }
    } catch (e) {
      // Erro ao criar notificação de movimentação
    }
  }

  // Criar notificação de checklist de frota
  Future<void> createFleetInspection({
    required String vehicleName,
    required String checklistStatus,
    String? checklistId,
  }) async {
    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      final selectedUnit = ref.read(currentUnitIdProvider);
      
      if (user != null && selectedUnit != null) {
        await NotificationService.createFleetInspection(
          vehicleName: vehicleName,
          checklistStatus: checklistStatus,
          unitId: selectedUnit,
          userId: user.id,
          checklistId: checklistId,
        );
      }
    } catch (e) {
      // Erro ao criar notificação de checklist
    }
  }

  // Atualizar filtros
  void updateFilters(NotificationFilters filters) {
    // Método removido - usar diretamente o StateNotifier
  }

  // Limpar filtros
  void clearFilters() {
    ref.read(notificationFiltersProvider.notifier).clearFilters();
  }
}

// Provider para estatísticas de notificações
final notificationStatsProvider = Provider.autoDispose<AsyncValue<NotificationStats>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);

  return notificationsAsync.when(
    data: (notifications) {
      final stats = NotificationStats.fromNotifications(notifications);
      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Classe para estatísticas de notificações
class NotificationStats {
  final int total;
  final int unread;
  final int byPriority;
  final Map<NotificationType, int> byType;
  final Map<NotificationPriority, int> byPriorityMap;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.byPriority,
    required this.byType,
    required this.byPriorityMap,
  });

  factory NotificationStats.fromNotifications(List<AppNotification> notifications) {
    final byType = <NotificationType, int>{};
    final byPriorityMap = <NotificationPriority, int>{};
    int unread = 0;

    for (final notification in notifications) {
      // Contar por tipo
      byType[notification.type] = (byType[notification.type] ?? 0) + 1;
      
      // Contar por prioridade
      byPriorityMap[notification.priority] = 
          (byPriorityMap[notification.priority] ?? 0) + 1;
      
      // Contar não lidas
      if (!notification.isRead) {
        unread++;
      }
    }

    return NotificationStats(
      total: notifications.length,
      unread: unread,
      byPriority: byPriorityMap[NotificationPriority.high] ?? 0,
      byType: byType,
      byPriorityMap: byPriorityMap,
    );
  }
}