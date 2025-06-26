import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestaocbmgo/app/home/widgets/welcome_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão CBMGO'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeWidget(),
            const SizedBox(height: 24),
            Text(
              'Módulos do Sistema',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: <Widget>[
                  _buildMenuCard(
                    context,
                    icon: Icons.assignment,
                    title: 'Gestão de Vistorias',
                    onTap: () => context.go('/inspections'),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Gestão de Almoxarifado',
                    onTap: () => context.go('/stock'),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.directions_car,
                    title: 'Gestão de Frotas',
                    onTap: () => context.go('/fleet'),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.swap_horiz,
                    title: 'Gestão de Trocas de Serviços',
                    onTap: () => context.go('/trade-services'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}