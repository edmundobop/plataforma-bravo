import 'package:flutter/material.dart';
import 'package:gestaocbmgo/app/stock/consumables/views/product_registration_screen.dart';

class ConsumablesDashboardScreen extends StatefulWidget {
  const ConsumablesDashboardScreen({super.key});

  @override
  State<ConsumablesDashboardScreen> createState() => _ConsumablesDashboardScreenState();
}

class _ConsumablesDashboardScreenState extends State<ConsumablesDashboardScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  final List<Widget> _screens = [
    const Center(child: Text('Visão Geral de Consumíveis')),
    const ProductRegistrationScreen(),
    const Center(child: Text('Entrada e Saída')),
    const Center(child: Text('Controle de Estoque')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            extended: _isExpanded,
            leading: IconButton(
              icon: Icon(_isExpanded ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Visão Geral'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Produtos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.swap_horiz_outlined),
                selectedIcon: Icon(Icons.swap_horiz),
                label: Text('Entradas/Saídas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Estoque'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}