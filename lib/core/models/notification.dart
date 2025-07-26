import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  stockAlert('stock_alert', 'Alerta de Estoque', '📦'),
  stockMovement('stock_movement', 'Movimentação de Estoque', '📋'),
  fleetInspection('fleet_inspection', 'Inspeção de Frota', '🚗'),
  fleetMaintenance('fleet_maintenance', 'Manutenção de Frota', '🔧'),
  userManagement('user_management', 'Gestão de Usuários', '👥'),
  systemAlert('system_alert', 'Alerta do Sistema', '⚠️'),
  general('general', 'Geral', '📢');

  const NotificationType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

enum NotificationPriority {
  low('low', 'Baixa', 1),
  medium('medium', 'Média', 2),
  high('high', 'Alta', 3),
  critical('critical', 'Crítica', 4);

  const NotificationPriority(this.value, this.displayName, this.level);
  final String value;
  final String displayName;
  final int level;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final String? moduleId; // Módulo que gerou a notificação
  final String unitId; // Unidade relacionada (multi-tenant)
  final String? userId; // Usuário específico (opcional)
  final String? targetUserId; // Usuário destinatário (opcional)
  final Map<String, dynamic>? metadata; // Dados extras (IDs, links, etc.)
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl; // URL para ação relacionada
  final DateTime? expiresAt; // Data de expiração (opcional)

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.moduleId,
    required this.unitId,
    this.userId,
    this.targetUserId,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    this.expiresAt,
  });

  // Verificar se a notificação está expirada
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Verificar se é uma notificação recente (últimas 24h)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 24;
  }

  // Cor baseada na prioridade
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return '#4CAF50'; // Verde
      case NotificationPriority.medium:
        return '#FF9800'; // Laranja
      case NotificationPriority.high:
        return '#F44336'; // Vermelho
      case NotificationPriority.critical:
        return '#9C27B0'; // Roxo
    }
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.fromString(data['type'] ?? 'general'),
      priority: NotificationPriority.fromString(data['priority'] ?? 'medium'),
      moduleId: data['moduleId'],
      unitId: data['unitId'] ?? '',
      userId: data['userId'],
      targetUserId: data['targetUserId'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata']) 
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      actionUrl: data['actionUrl'],
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'moduleId': moduleId,
      'unitId': unitId,
      'userId': userId,
      'targetUserId': targetUserId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionUrl': actionUrl,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    String? moduleId,
    String? unitId,
    String? userId,
    String? targetUserId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      moduleId: moduleId ?? this.moduleId,
      unitId: unitId ?? this.unitId,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: ${type.value}, priority: ${priority.value}, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}