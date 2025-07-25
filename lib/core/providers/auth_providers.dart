import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Provider do serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider do estado de autenticação
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider do usuário atual (AppUser)
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentAppUser;
});

// Provider para verificar se o usuário está logado
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider para verificar se o usuário é admin
final isAdminProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.role == UserRole.admin,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider da lista de usuários (apenas para admin)
final usersListProvider = FutureProvider<List<AppUser>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAllUsers();
});

// Notifier para operações de autenticação
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  final AuthService _authService;

  // Login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Registro
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? department,
    String? phone,
    List<String>? unitIds,
    String? currentUnitId,
    bool isGlobalAdmin = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        department: department,
        phone: phone,
        unitIds: unitIds,
        currentUnitId: currentUnitId,
        isGlobalAdmin: isGlobalAdmin,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Logout
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reset de senha
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Atualizar perfil
  Future<void> updateProfile(AppUser user) async {
    state = const AsyncValue.loading();
    try {
      await _authService.updateUserProfile(user);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Alterar status do usuário
  Future<void> toggleUserStatus(String uid, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      await _authService.toggleUserStatus(uid, isActive);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Alterar role do usuário
  Future<void> updateUserRole(String uid, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      await _authService.updateUserRole(uid, role);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Atualizar unidade atual do usuário
  Future<void> updateUserCurrentUnit(String uid, String unitId) async {
    state = const AsyncValue.loading();
    try {
      await _authService.updateUserCurrentUnit(uid, unitId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Adicionar unidade ao usuário
  Future<void> addUserUnit(String uid, String unitId) async {
    state = const AsyncValue.loading();
    try {
      await _authService.addUserUnit(uid, unitId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Remover unidade do usuário
  Future<void> removeUserUnit(String uid, String unitId) async {
    state = const AsyncValue.loading();
    try {
      await _authService.removeUserUnit(uid, unitId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Definir usuário como admin global
  Future<void> setGlobalAdmin(String uid, bool isGlobalAdmin) async {
    state = const AsyncValue.loading();
    try {
      await _authService.setGlobalAdmin(uid, isGlobalAdmin);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Atualizar dados específicos do perfil do usuário
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _authService.updateUserProfileData(currentUser.uid, data);
      }
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Criar usuário (método para compatibilidade com user management)
  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? department,
    String? phone,
    List<String>? unitIds,
    bool isGlobalAdmin = false,
  }) async {
    await register(
      email: email,
      password: password,
      name: name,
      role: role,
      department: department,
      phone: phone,
      unitIds: unitIds,
      isGlobalAdmin: isGlobalAdmin,
    );
  }
}

// Provider do notifier de autenticação
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Alias para compatibilidade com user management
final userManagementProvider = authNotifierProvider;