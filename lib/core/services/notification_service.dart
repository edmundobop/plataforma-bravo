import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notifications';

  // Criar uma nova notificação
  static Future<String> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    required String unitId,
    NotificationPriority priority = NotificationPriority.medium,
    String? moduleId,
    String? userId,
    String? targetUserId,
    Map<String, dynamic>? metadata,
    String? actionUrl,
    DateTime? expiresAt,
  }) async {
    try {
      final notification = AppNotification(
        id: '', // Será gerado pelo Firestore
        title: title,
        message: message,
        type: type,
        priority: priority,
        moduleId: moduleId,
        unitId: unitId,
        userId: userId,
        targetUserId: targetUserId,
        metadata: metadata,
        createdAt: DateTime.now(),
        actionUrl: actionUrl,
        expiresAt: expiresAt,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(notification.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar notificação: $e');
    }
  }

  // Buscar notificações por unidade
  static Stream<List<AppNotification>> getNotificationsByUnit(
    String unitId, {
    int limit = 50,
    bool onlyUnread = false,
    NotificationType? filterType,
    NotificationPriority? filterPriority,
  }) {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Filtrar apenas não lidas
      if (onlyUnread) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Filtrar por tipo
      if (filterType != null) {
        query = query.where('type', isEqualTo: filterType.value);
      }

      // Filtrar por prioridade
      if (filterPriority != null) {
        query = query.where('priority', isEqualTo: filterPriority.value);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .where((notification) => !notification.isExpired) // Filtrar expiradas
            .toList();
      });
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  // Buscar notificações para um usuário específico
  static Stream<List<AppNotification>> getNotificationsForUser(
    String userId,
    String unitId, {
    int limit = 50,
    bool onlyUnread = false,
  }) {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .where((notification) {
              // Filtrar notificações relevantes para o usuário
              final isForUser = notification.targetUserId == null || 
                               notification.targetUserId == userId;
              final isNotExpired = !notification.isExpired;
              final isReadFilter = !onlyUnread || !notification.isRead;
              
              return isForUser && isNotExpired && isReadFilter;
            })
            .toList();
      });
    } catch (e) {
      throw Exception('Erro ao buscar notificações do usuário: $e');
    }
  }

  // Marcar notificação como lida
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao marcar notificação como lida: $e');
    }
  }

  // Marcar múltiplas notificações como lidas
  static Future<void> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();
      final timestamp = Timestamp.fromDate(DateTime.now());

      for (final id in notificationIds) {
        final docRef = _firestore.collection(_collection).doc(id);
        batch.update(docRef, {
          'isRead': true,
          'readAt': timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao marcar notificações como lidas: $e');
    }
  }

  // Marcar todas as notificações de uma unidade como lidas
  static Future<void> markAllAsReadForUnit(String unitId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .where('isRead', isEqualTo: false)
          .get();

      if (query.docs.isEmpty) return;

      final batch = _firestore.batch();
      final timestamp = Timestamp.fromDate(DateTime.now());

      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  // Deletar notificação
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar notificação: $e');
    }
  }

  // Deletar notificações expiradas
  static Future<void> deleteExpiredNotifications() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final query = await _firestore
          .collection(_collection)
          .where('expiresAt', isLessThan: now)
          .get();

      if (query.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar notificações expiradas: $e');
    }
  }

  // Contar notificações não lidas
  static Future<int> getUnreadCount(String unitId, {String? userId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('unitId', isEqualTo: unitId)
          .where('isRead', isEqualTo: false);

      final snapshot = await query.get();
      
      if (userId != null) {
        // Filtrar para usuário específico
        return snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .where((notification) {
              final isForUser = notification.targetUserId == null || 
                               notification.targetUserId == userId;
              return isForUser && !notification.isExpired;
            })
            .length;
      }

      // Contar todas as não lidas da unidade
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .where((notification) => !notification.isExpired)
          .length;
    } catch (e) {
      throw Exception('Erro ao contar notificações não lidas: $e');
    }
  }

  // Buscar notificação por ID
  static Future<AppNotification?> getNotificationById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return AppNotification.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar notificação: $e');
    }
  }

  // Métodos de conveniência para criar notificações específicas
  
  // Notificação de estoque baixo
  static Future<String> createStockAlert({
    required String productName,
    required int currentStock,
    required int minStock,
    required String unitId,
    String? productId,
  }) async {
    return createNotification(
      title: 'Estoque Baixo',
      message: '$productName está com estoque baixo ($currentStock unidades). Mínimo: $minStock',
      type: NotificationType.stockAlert,
      priority: NotificationPriority.high,
      unitId: unitId,
      moduleId: 'stock',
      metadata: {
        'productId': productId,
        'currentStock': currentStock,
        'minStock': minStock,
      },
      actionUrl: '/stock/products',
    );
  }

  // Notificação de movimentação de estoque
  static Future<String> createStockMovement({
    required String productName,
    required String movementType,
    required int quantity,
    required String unitId,
    required String userId,
    String? movementId,
  }) async {
    return createNotification(
      title: 'Movimentação de Estoque',
      message: '$movementType: $quantity unidades de $productName',
      type: NotificationType.stockMovement,
      priority: NotificationPriority.medium,
      unitId: unitId,
      userId: userId,
      moduleId: 'stock',
      metadata: {
        'movementId': movementId,
        'movementType': movementType,
        'quantity': quantity,
      },
      actionUrl: '/stock/movement',
    );
  }

  // Notificação de checklist de frota
  static Future<String> createFleetInspection({
    required String vehicleName,
    required String checklistStatus,
    required String unitId,
    required String userId,
    String? checklistId,
  }) async {
    final priority = checklistStatus == 'pendente' 
        ? NotificationPriority.high 
        : NotificationPriority.medium;

    return createNotification(
      title: 'Checklist de Viatura',
      message: 'Checklist da viatura $vehicleName: $checklistStatus',
      type: NotificationType.fleetInspection,
      priority: priority,
      unitId: unitId,
      userId: userId,
      moduleId: 'fleet',
      metadata: {
        'checklistId': checklistId,
        'vehicleName': vehicleName,
        'status': checklistStatus,
      },
      actionUrl: '/fleet',
    );
  }
}