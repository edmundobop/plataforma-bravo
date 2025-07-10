import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/vehicle.dart';
import '../../../../core/providers/providers.dart';

class VehicleRegistrationScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle; // For editing existing vehicles

  const VehicleRegistrationScreen({super.key, this.vehicle});

  @override
  ConsumerState<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState
    extends ConsumerState<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _observationController = TextEditingController();

  VehicleType? _selectedVehicleType;
  VehicleStatus? _selectedVehicleStatus;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final vehicle = widget.vehicle!;
    _nameController.text = vehicle.name;
    _licensePlateController.text = vehicle.licensePlate;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _observationController.text = vehicle.observation ?? '';
    _selectedVehicleType = vehicle.type;
    _selectedVehicleStatus = vehicle.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licensePlateController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleService = ref.read(vehicleServiceProvider);
      final now = DateTime.now();

      final vehicle = Vehicle(
        id: widget.vehicle?.id,
        name: _nameController.text.trim(),
        type: _selectedVehicleType!,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        status: _selectedVehicleStatus!,
        observation: _observationController.text.trim().isEmpty
            ? null
            : _observationController.text.trim(),
        createdAt: widget.vehicle?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.vehicle == null) {
        // Create new vehicle
        await vehicleService.createVehicle(vehicle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viatura cadastrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing vehicle
        await vehicleService.updateVehicle(vehicle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viatura atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar viatura: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    final isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Editar Viatura' : 'Cadastrar Viatura'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Form(
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
                        'Informações da Viatura',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<VehicleType>(
                        value: _selectedVehicleType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Viatura *',
                          border: OutlineInputBorder(),
                        ),
                        items: VehicleType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                                type.toString().split('.').last.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Tipo é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Viatura *',
                          hintText: 'Ex: Auto Bomba Tanque',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licensePlateController,
                        decoration: const InputDecoration(
                          labelText: 'Placa *',
                          hintText: 'ABC-1234',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Placa é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo *',
                          hintText: 'Ex: Mercedes-Benz',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Modelo é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Ano *',
                          hintText: '2023',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ano é obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Digite um ano válido';
                          }
                          final year = int.parse(value);
                          if (year < 1900 || year > DateTime.now().year + 5) {
                            return 'Ano inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<VehicleStatus>(
                        value: _selectedVehicleStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items: VehicleStatus.values.map((status) {
                          String statusText;
                          switch (status) {
                            case VehicleStatus.available:
                              statusText = 'Disponível';
                              break;
                            case VehicleStatus.inMaintenance:
                              statusText = 'Em Manutenção';
                              break;
                            case VehicleStatus.inUse:
                              statusText = 'Em Uso';
                              break;
                            case VehicleStatus.unavailable:
                              statusText = 'Indisponível';
                              break;
                          }
                          return DropdownMenuItem(
                            value: status,
                            child: Text(statusText),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleStatus = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Status é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observationController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Informações adicionais (opcional)',
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
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Color(0xFFD32F2F))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Atualizar' : 'Cadastrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
