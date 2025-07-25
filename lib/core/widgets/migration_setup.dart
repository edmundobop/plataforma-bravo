import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/migration_helper.dart';

/// Widget para configuração inicial e migração do sistema
class MigrationSetup extends ConsumerStatefulWidget {
  final Widget child;
  
  const MigrationSetup({super.key, required this.child});

  @override
  ConsumerState<MigrationSetup> createState() => _MigrationSetupState();
}

class _MigrationSetupState extends ConsumerState<MigrationSetup> {
  bool _isChecking = true;
  bool _needsMigration = false;
  bool _isMigrating = false;
  String _migrationStatus = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  Future<void> _checkMigrationStatus() async {
    try {
      final needsMigration = await MigrationHelper.needsMigration();
      if (mounted) {
        setState(() {
          _isChecking = false;
          _needsMigration = needsMigration;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _error = 'Erro ao verificar migração: $e';
        });
      }
    }
  }

  Future<void> _runMigration() async {
    setState(() {
      _isMigrating = true;
      _migrationStatus = 'Iniciando migração...';
      _error = null;
    });

    try {
      await MigrationHelper.runFullMigration();
      
      setState(() {
        _migrationStatus = 'Validando migração...';
      });
      
      final isValid = await MigrationHelper.validateMigration();
      
      if (mounted) {
        if (isValid) {
          setState(() {
            _isMigrating = false;
            _needsMigration = false;
            _migrationStatus = 'Migração concluída com sucesso!';
          });
        } else {
          setState(() {
            _isMigrating = false;
            _error = 'Falha na validação da migração';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMigrating = false;
          _error = 'Erro durante a migração: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoadingScreen('Verificando configuração do sistema...');
    }

    if (_error != null) {
      return _buildErrorScreen();
    }

    if (_needsMigration) {
      return _buildMigrationScreen();
    }

    return widget.child;
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Erro na Configuração',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isChecking = true;
                  });
                  _checkMigrationStatus();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMigrationScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Configuração Inicial',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'O sistema precisa ser configurado para suportar múltiplas unidades do CBMGO.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isMigrating) ...
                [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _migrationStatus,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ]
              else ...
                [
                  ElevatedButton(
                    onPressed: _runMigration,
                    child: const Text('Configurar Sistema'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _needsMigration = false;
                      });
                    },
                    child: const Text('Pular (Não Recomendado)'),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider para verificar status da migração
final migrationStatusProvider = FutureProvider<bool>((ref) async {
  return await MigrationHelper.needsMigration();
});