import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/models/user.dart';

import 'package:go_router/go_router.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Gerenciar Usuários'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquisar usuários',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Lista de usuários
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((user) {
                  return user.name.toLowerCase().contains(_searchQuery) ||
                         user.email.toLowerCase().contains(_searchQuery) ||
                         user.role.displayName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('Nenhum usuário encontrado'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isCurrentUser = currentUser.value?.id == user.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: user.isActive ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.role.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!user.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Inativo',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (user.department != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Departamento: ${user.department}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            if (user.lastLoginAt != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Último acesso: ${_formatDate(user.lastLoginAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: isCurrentUser
                            ? const Icon(Icons.person, color: Colors.blue)
                            : PopupMenuButton<String>(
                                onSelected: (value) => _handleUserAction(value, user),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle_status',
                                    child: Row(
                                      children: [
                                        Icon(
                                          user.isActive ? Icons.block : Icons.check_circle,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(user.isActive ? 'Desativar' : 'Ativar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'change_role',
                                    child: Row(
                                      children: [
                                        Icon(Icons.admin_panel_settings, size: 20),
                                        SizedBox(width: 8),
                                        Text('Alterar Função'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reset_password',
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock_reset, size: 20),
                                        SizedBox(width: 8),
                                        Text('Resetar Senha'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar usuários: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(usersListProvider),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red.shade600;
      case UserRole.supervisor:
        return Colors.orange.shade600;
      case UserRole.user:
        return Colors.blue.shade600;
      case UserRole.viewer:
        return Colors.green.shade600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleUserAction(String action, AppUser user) {
    switch (action) {
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'change_role':
        _showChangeRoleDialog(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
    }
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Desativar' : 'Ativar'} Usuário'),
        content: Text(
          'Tem certeza que deseja ${user.isActive ? 'desativar' : 'ativar'} o usuário ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(user.isActive ? 'Desativar' : 'Ativar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.toggleUserStatus(user.id, !user.isActive);
      ref.refresh(usersListProvider);
    }
  }

  void _showChangeRoleDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alterar Função - ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<UserRole>(
              title: Text(role.displayName),
              value: role,
              groupValue: user.role,
              onChanged: (value) {
                if (value != null) {
                  Navigator.of(context).pop();
                  _changeUserRole(user, value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUserRole(AppUser user, UserRole newRole) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.updateUserRole(user.id, newRole);
    ref.refresh(usersListProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Função de ${user.name} alterada para ${newRole.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetUserPassword(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Senha'),
        content: Text(
          'Será enviado um email para ${user.email} com instruções para redefinir a senha. Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.resetPassword(user.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperação enviado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final departmentController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Usuário'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Campo obrigatório';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Campo obrigatório';
                    if (value!.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Departamento (opcional)'),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone (opcional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Função'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedRole = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                final authNotifier = ref.read(authNotifierProvider.notifier);
                await authNotifier.register(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
                  role: selectedRole,
                  department: departmentController.text.trim().isEmpty 
                    ? null : departmentController.text.trim(),
                  phone: phoneController.text.trim().isEmpty 
                    ? null : phoneController.text.trim(),
                );
                
                ref.refresh(usersListProvider);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário criado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}