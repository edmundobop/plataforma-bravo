import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InspectionsScreen extends StatelessWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Vistorias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: const Center(
        child: Text(
          'Módulo de Gestão de Vistorias em desenvolvimento',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}