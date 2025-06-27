import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream do usuário atual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream do AppUser atual
  Stream<AppUser?> get currentAppUser {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getAppUser(user.uid);
    });
  }

  // Login com email e senha
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar último login
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro de novo usuário (apenas admin pode fazer)
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? department,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Criar perfil do usuário no Firestore
        await _createUserProfile(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          department: department,
          phone: phone,
        );

        // Atualizar display name
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Buscar dados do usuário
  Future<AppUser?> getAppUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  // Atualizar perfil do usuário
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // Listar todos os usuários (apenas admin)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // Ativar/Desativar usuário
  Future<void> toggleUserStatus(String uid, bool isActive) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Erro ao alterar status do usuário: $e');
    }
  }

  // Alterar role do usuário
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role.value,
      });
    } catch (e) {
      throw Exception('Erro ao alterar role do usuário: $e');
    }
  }

  // Reset de senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Criar perfil do usuário no Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
    String? department,
    String? phone,
  }) async {
    final user = AppUser(
      id: uid,
      email: email,
      name: name,
      role: role,
      department: department,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toFirestore());
  }

  // Atualizar último login
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': Timestamp.now(),
    });
  }

  // Tratar exceções de autenticação
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  // Verificar se é o primeiro usuário (será admin)
  Future<bool> isFirstUser() async {
    try {
      final snapshot = await _firestore.collection('users').limit(1).get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }
}