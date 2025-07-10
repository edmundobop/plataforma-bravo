import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/checklist_viaturas/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Perfil do Usuário'),
      ),
      body: const Center(
        child: Text('Tela de Perfil do Usuário'),
      ),
    );
  }
}
