import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/fire_unit_providers.dart';
import '../../../core/widgets/unit_selector.dart';
import '../../../features/checklist_viaturas/utils/app_colors.dart';
import '../widgets/welcome_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    
    // Inicializar o listener de mudanças de unidade
    ref.watch(unitChangeListenerProvider);
    
    // Inicializar a seleção automática de unidade
    ref.watch(unitSelectionProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(211, 47, 47, 1),
              AppColors.darkRed,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho CBM-GO
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Título principal
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plataforma Bravo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Gestão CBM-GO',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu do usuário
                        PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          onSelected: (value) =>
                              _handleMenuAction(context, ref, value),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 20, color: AppColors.primaryRed),
                                  const SizedBox(width: 8),
                                  Text(currentUser.value?.name ?? 'Perfil'),
                                ],
                              ),
                            ),
                            if (isAdmin) ...[
                              const PopupMenuItem(
                                value: 'users',
                                child: Row(
                                  children: [
                                    Icon(Icons.people,
                                        size: 20, color: AppColors.primaryRed),
                                    SizedBox(width: 8),
                                    Text('Usuários'),
                                  ],
                                ),
                              ),
                            ],
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout,
                                      size: 20, color: AppColors.primaryRed),
                                  SizedBox(width: 8),
                                  Text('Sair'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Seletor de Unidade
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const UnitSelector(
                  showLabel: false,
                  compact: false,
                ),
              ),
              // Conteúdo principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Seção de Movimentações Recentes
                      // const RecentMovementsWidget(),  // Comente esta linha
                      const WelcomeWidget(), // Widget de boas-vindas
                      // Menu de módulos
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Módulos do Sistema',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkRed,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                  children: <Widget>[
                                    _buildModernMenuCard(
                                      context,
                                      icon: Icons.assignment_turned_in,
                                      title: 'Gestão de\nVistorias',
                                      subtitle: 'Inspeções e relatórios',
                                      color: AppColors.primaryRed,
                                      onTap: () => context.go('/inspections'),
                                    ),
                                    _buildModernMenuCard(
                                      context,
                                      icon: Icons.inventory_2,
                                      title: 'Gestão de\nAlmoxarifado',
                                      subtitle: 'Controle de estoque',
                                      color: const Color(0xFF2E7D32),
                                      onTap: () => context.go('/stock'),
                                    ),
                                    _buildModernMenuCard(
                                      context,
                                      icon: Icons.directions_car,
                                      title: 'Gestão de Frota',
                                      subtitle: 'Inspeção de veículos',
                                      color: const Color(0xFF1976D2),
                                      onTap: () => context.go('/fleet'),
                                    ),
                                    _buildModernMenuCard(
                                      context,
                                      icon: Icons.business_center,
                                      title: 'Gestão\nOperacional',
                                      subtitle: 'SOP - Sessão Operacional',
                                      color: const Color(0xFF7B1FA2),
                                      onTap: () =>
                                          context.go('/trade-services'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'profile':
        _showProfileDialog(context, ref);
        break;
      case 'users':
        context.go('/users');
        break;
      case 'logout':
        _handleLogout(context, ref);
        break;
    }
  }

  void _showProfileDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentUnit = ref.watch(currentUnitProvider);
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Meu Perfil',
                  style: TextStyle(
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileInfo('Nome', currentUser.name),
                const SizedBox(height: 12),
                _buildProfileInfo('Email', currentUser.email),
                const SizedBox(height: 12),
                _buildProfileInfo(
                    'Cargo', currentUser.role.toString().split('.').last),
                const SizedBox(height: 12),
                _buildProfileInfo(
                  'Unidade', 
                  currentUnit?.name ?? 'Nenhuma unidade selecionada'
                ),
                if (currentUser.isGlobalAdmin) ...
                  [
                    const SizedBox(height: 12),
                    _buildProfileInfo('Tipo', 'Administrador Global'),
                  ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.darkRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirmar Saída',
              style: TextStyle(
                color: AppColors.darkRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair do sistema?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
