import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin('admin', 'Administrador'),
  user('user', 'Usuário'),
  viewer('viewer', 'Visualizador'),
  supervisor('supervisor', 'Supervisor');

  const UserRole(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? department;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImageUrl;
  // Multi-tenant fields
  final String? currentUnitId; // Unidade atualmente selecionada
  final List<String> unitIds; // Lista de unidades que o usuário tem acesso
  final bool isGlobalAdmin; // Admin global (acesso a todas as unidades)

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.currentUnitId,
    this.unitIds = const [],
    this.isGlobalAdmin = false,
  });

  // Permissões baseadas no role e multi-tenancy
  bool get canManageUsers => isGlobalAdmin || role == UserRole.admin;
  bool get canCreateProducts => role == UserRole.admin || role == UserRole.user;
  bool get canEditProducts => role == UserRole.admin || role == UserRole.user;
  bool get canDeleteProducts => role == UserRole.admin;
  bool get canManageStock => role == UserRole.admin || role == UserRole.user;
  bool get canApproveMovements => role == UserRole.admin || role == UserRole.supervisor;
  bool get canViewReports => true; // Todos podem ver relatórios
  bool get canExportData => role == UserRole.admin || role == UserRole.supervisor;
  bool get canSwitchUnits => unitIds.length > 1 || isGlobalAdmin;
  bool get hasUnitAccess => currentUnitId != null || isGlobalAdmin;
  
  // Verificar se tem acesso a uma unidade específica
  bool hasAccessToUnit(String unitId) {
    return isGlobalAdmin || unitIds.contains(unitId);
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'user'),
      department: data['department'],
      phone: data['phone'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      profileImageUrl: data['profileImageUrl'],
      currentUnitId: data['currentUnitId'],
      unitIds: List<String>.from(data['unitIds'] ?? []),
      isGlobalAdmin: data['isGlobalAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
      'department': department,
      'phone': phone,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'profileImageUrl': profileImageUrl,
      'currentUnitId': currentUnitId,
      'unitIds': unitIds,
      'isGlobalAdmin': isGlobalAdmin,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? department,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImageUrl,
    String? currentUnitId,
    List<String>? unitIds,
    bool? isGlobalAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentUnitId: currentUnitId ?? this.currentUnitId,
      unitIds: unitIds ?? this.unitIds,
      isGlobalAdmin: isGlobalAdmin ?? this.isGlobalAdmin,
    );
  }
}