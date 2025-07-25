import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

/// Widget de debug para facilitar o login durante desenvolvimento
class DebugLogin extends ConsumerWidget {
  const DebugLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);

    if (isLoggedIn) {
      return currentUser.when(
        data: (user) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✅ Usuário Logado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text('Email: ${user?.email ?? "N/A"}'),
              Text('Nome: ${user?.name ?? "N/A"}'),
              Text('Role: ${user?.role.value ?? "N/A"}'),
              Text('Unidades: ${user?.unitIds.length ?? 0}'),
              Text('Admin Global: ${user?.isGlobalAdmin ?? false}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => authNotifier.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Erro: $error'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔐 Debug Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _loginAsAdmin(authNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login Admin'),
              ),
              ElevatedButton(
                onPressed: () => _loginAsUser(authNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login Usuário'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loginAsAdmin(AuthNotifier authNotifier) async {
    try {
      await authNotifier.signIn(
        email: 'admin@bombeiros.go.gov.br',
        password: '123456', // Senha padrão para teste
      );
    } catch (e) {
      print('Erro ao fazer login como admin: $e');
    }
  }

  Future<void> _loginAsUser(AuthNotifier authNotifier) async {
    try {
      await authNotifier.signIn(
        email: 'user@bombeiros.go.gov.br',
        password: '123456', // Senha padrão para teste
      );
    } catch (e) {
      print('Erro ao fazer login como usuário: $e');
    }
  }
}