import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/checklist.dart';
import '../../../../core/models/vehicle.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/providers/fire_unit_providers.dart';

class ChecklistFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const ChecklistFormScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<ChecklistFormScreen> createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends ConsumerState<ChecklistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _generalObservationController = TextEditingController();
  List<ChecklistItem> _checklistItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChecklistItems();
  }

  void _initializeChecklistItems() {
    // TODO: Load checklist items from a predefined list or configuration
    // For now, using a static list
    _checklistItems = [
      ChecklistItem(description: 'Nível de óleo', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Nível de água', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Pneus (calibragem e estado)', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Luzes (faróis, lanternas, freio)', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Freios', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Extintor de incêndio', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Macaco e chave de roda', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Triângulo de segurança', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Documentação (porte obrigatório)', status: ChecklistItemStatus.na),
      ChecklistItem(description: 'Limpeza interna e externa', status: ChecklistItemStatus.na),
    ];
  }

  Future<void> _submitChecklist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final checklistService = ref.read(checklistServiceProvider);
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser == null) {
        throw Exception('Usuário não autenticado.');
      }

      // Determine overall checklist status
      ChecklistStatus overallStatus = ChecklistStatus.completed;
      if (_checklistItems.any((item) => item.status == ChecklistItemStatus.notOk)) {
        overallStatus = ChecklistStatus.failed;
      }

      final currentUnitId = ref.read(currentUnitIdProvider);
      if (currentUnitId == null) {
        throw Exception('Unidade não selecionada.');
      }

      final checklist = Checklist(
        vehicleId: widget.vehicleId,
        userId: currentUser.id,
        unitId: currentUnitId,
        checklistDate: DateTime.now(),
        status: overallStatus,
        generalObservations: _generalObservationController.text.trim().isEmpty
            ? null
            : _generalObservationController.text.trim(),
        items: _checklistItems,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await checklistService.createChecklist(checklist);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checklist registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar checklist: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: $e');
        print('Stack: $stack');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleServiceProvider).getVehicleById(widget.vehicleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Checklist'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Vehicle?>(
        future: vehicleAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar viatura: ${snapshot.error}'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Viatura não encontrada.'));
          } else {
            final vehicle = snapshot.data!;
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Viatura: ${vehicle.name} (${vehicle.licensePlate})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Itens do Checklist',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _checklistItems.length,
                              itemBuilder: (context, index) {
                                final item = _checklistItems[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RadioListTile<ChecklistItemStatus>(
                                                title: const Text('OK'),
                                                value: ChecklistItemStatus.ok,
                                                groupValue: item.status,
                                                onChanged: (value) {
                                                  setState(() {
                                                    item.status = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile<ChecklistItemStatus>(
                                                title: const Text('Não OK'),
                                                value: ChecklistItemStatus.notOk,
                                                groupValue: item.status,
                                                onChanged: (value) {
                                                  setState(() {
                                                    item.status = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile<ChecklistItemStatus>(
                                                title: const Text('N/A'),
                                                value: ChecklistItemStatus.na,
                                                groupValue: item.status,
                                                onChanged: (value) {
                                                  setState(() {
                                                    item.status = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item.status == ChecklistItemStatus.notOk)
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              labelText: 'Observação (Obrigatório)',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 2,
                                            validator: (value) {
                                              if (item.status == ChecklistItemStatus.notOk && (value == null || value.trim().isEmpty)) {
                                                return 'Observação é obrigatória para itens Não OK';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              item.observation = value.trim();
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _generalObservationController,
                              decoration: const InputDecoration(
                                labelText: 'Observações Gerais (Opcional)',
                                hintText: 'Observações sobre o checklist geral',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitChecklist,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Registrar Checklist'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}