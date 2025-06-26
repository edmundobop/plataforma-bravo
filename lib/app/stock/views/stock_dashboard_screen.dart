import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';

class StockDashboardScreen extends ConsumerStatefulWidget {
  const StockDashboardScreen({super.key});

  @override
  ConsumerState<StockDashboardScreen> createState() => _StockDashboardScreenState();
}

class _StockDashboardScreenState extends ConsumerState<StockDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const _DashboardOverview(),
      const _ConsumablesSection(),
      const _EquipmentSection(),
      const _CautelasSection(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Almoxarifado'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Voltar ao Menu Principal',
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Consumíveis'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build),
                label: Text('Equipamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Cautelas'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockStatsAsync = ref.watch(stockStatsProvider);
    final lowStockProductsAsync = ref.watch(lowStockProductsStreamProvider);
    final recentMovementsAsync = ref.watch(recentMovementsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Estoque'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estatísticas gerais
            Text(
              'Visão Geral',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            stockStatsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatsCard(
                      title: 'Total de Produtos',
                      value: stats['totalProducts'].toString(),
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatsCard(
                      title: 'Total de Itens',
                      value: stats['totalItems'].toString(),
                      icon: Icons.widgets,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatsCard(
                      title: 'Estoque Baixo',
                      value: stats['lowStockProducts'].toString(),
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatsCard(
                      title: 'Estoque Crítico',
                      value: stats['criticalStockProducts'].toString(),
                      icon: Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Erro ao carregar estatísticas: $error'),
            ),
            const SizedBox(height: 32),
            
            // Ações rápidas
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Nova Movimentação',
                    subtitle: 'Registrar entrada ou saída',
                    icon: Icons.swap_horiz,
                    color: Colors.blue,
                    onTap: () => context.push('/stock/movement'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Cadastrar Produto',
                    subtitle: 'Adicionar novo produto',
                    icon: Icons.add_box,
                    color: Colors.green,
                    onTap: () => context.push('/stock/product-registration'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Lista de Produtos',
                    subtitle: 'Ver todos os produtos',
                    icon: Icons.list,
                    color: Colors.purple,
                    onTap: () => context.push('/stock/products'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Produtos com estoque baixo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Produtos com estoque baixo
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Produtos com Estoque Baixo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          lowStockProductsAsync.when(
                            data: (products) {
                              if (products.isEmpty) {
                                return const Text('Nenhum produto com estoque baixo');
                              }
                              return Column(
                                children: products.take(5).map((product) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getStockStatusColor(product),
                                      child: Text(
                                        product.currentStock.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(product.name),
                                    subtitle: Text('${product.category} - ${product.stockStatus}'),
                                    trailing: Text('${product.currentStock} ${product.unit}'),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text('Erro: $error'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Movimentações recentes
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movimentações Recentes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          recentMovementsAsync.when(
                            data: (movements) {
                              if (movements.isEmpty) {
                                return const Text('Nenhuma movimentação registrada');
                              }
                              return Column(
                                children: movements.take(5).map((movement) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: movement.type == MovementType.entry 
                                          ? Colors.green 
                                          : Colors.red,
                                      child: Icon(
                                        movement.type == MovementType.entry 
                                            ? Icons.arrow_downward 
                                            : Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(movement.productName),
                                    subtitle: Text(
                                      '${movement.type == MovementType.entry ? 'Entrada' : 'Saída'} - ${movement.reason}',
                                    ),
                                    trailing: Text(
                                      '${movement.type == MovementType.entry ? '+' : '-'}${movement.quantity}',
                                      style: TextStyle(
                                        color: movement.type == MovementType.entry 
                                            ? Colors.green 
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text('Erro: $error'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockStatusColor(Product product) {
    switch (product.stockStatus) {
      case 'Crítico':
        return Colors.red;
      case 'Baixo':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _ConsumablesSection extends ConsumerWidget {
  const _ConsumablesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumíveis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    title: 'Total de Produtos',
                    value: productsAsync.when(
                      data: (products) => products.length.toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erro',
                    ),
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeatureCard(
                    title: 'Estoque Baixo',
                    value: productsAsync.when(
                      data: (products) => products
                          .where((p) => p.currentStock <= p.minStock)
                          .length
                          .toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erro',
                    ),
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeatureCard(
                    title: 'Categorias',
                    value: productsAsync.when(
                      data: (products) => products
                          .map((p) => p.category)
                          .toSet()
                          .length
                          .toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erro',
                    ),
                    icon: Icons.category,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/stock/products'),
                    icon: const Icon(Icons.list),
                    label: const Text('Ver Lista de Produtos'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/stock/product-registration'),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Produto'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/stock/movement'),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Nova Movimentação'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _FeatureCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentSection extends StatelessWidget {
  const _EquipmentSection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamentos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Seção de Equipamentos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Em desenvolvimento...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CautelasSection extends StatelessWidget {
  const _CautelasSection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cautelas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Seção de Cautelas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Em desenvolvimento...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}