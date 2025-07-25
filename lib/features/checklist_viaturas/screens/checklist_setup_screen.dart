import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/providers/fire_unit_providers.dart';
import '../models/vehicle_checklist.dart';
import '../utils/app_colors.dart';
import '../utils/checklist_data.dart';
import 'checklist_screen.dart';

class ChecklistSetupScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const ChecklistSetupScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<ChecklistSetupScreen> createState() =>
      _ChecklistSetupScreenState();
}

class _ChecklistSetupScreenState extends ConsumerState<ChecklistSetupScreen> {
  String _selectedAla = 'Alpha';
  final DateTime _currentDateTime =
      DateTime.now(); // Data/hora fixa (não editável)

  final List<String> _alas = [
    'Alpha',
    'Bravo',
    'Charlie',
    'Delta',
  ];

  String _getVehicleTypeDisplayName(VehicleType type) {
    switch (type) {
      case VehicleType.abt:
        return 'Auto Bomba Tanque';
      case VehicleType.abtf:
        return 'Auto Bomba Tanque Florestal';
      case VehicleType.ur:
        return 'Unidade de Resgate';
      case VehicleType.asa:
        return 'Auto Socorro de Urgência';
      case VehicleType.av:
        return 'Ambulância de Suporte Avançado';
    }
  }

  void _startChecklist() {
    final currentUnitId = ref.read(currentUnitIdProvider);
    
    if (currentUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Unidade atual não encontrada'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Criar as categorias baseadas no tipo de veículo
    final categories = ChecklistData.getCategoriesForVehicleType(
        _getVehicleTypeDisplayName(widget.vehicle.type));

    // Criar o checklist
    final checklist = VehicleChecklist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      unitId: currentUnitId,
      vehicleId: widget.vehicle.id ?? '',
      vehicleType: _getVehicleTypeDisplayName(widget.vehicle.type),
      vehiclePlate: widget.vehicle.licensePlate,
      responsibleName:
          'Usuário Atual', // TODO: Pegar do contexto de autenticação
      responsibleRank: 'Soldado', // TODO: Pegar do contexto de autenticação
      responsibleRegistration:
          '123456', // TODO: Pegar do contexto de autenticação
      date: _currentDateTime,
      categories: categories,
    );

    // Navegar para a tela do checklist
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistScreen(checklist: checklist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Checklist'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32, // Considera o padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryRed.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.fire_truck,
                          size: 40,
                          color: AppColors.primaryRed,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Checklist de Viatura',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Configure as informações do checklist',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informações da Viatura
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.fire_truck,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Informações da Viatura',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Nome da Viatura
                        _buildInfoRow('Nome:', widget.vehicle.name),
                        const SizedBox(height: 6),

                        // Tipo da Viatura
                        _buildInfoRow('Tipo:',
                            _getVehicleTypeDisplayName(widget.vehicle.type)),
                        const SizedBox(height: 6),

                        // Placa
                        _buildInfoRow('Placa:', widget.vehicle.licensePlate),
                        const SizedBox(height: 6),

                        // Modelo
                        _buildInfoRow('Modelo:', widget.vehicle.model),
                        const SizedBox(height: 6),

                        // Ano
                        _buildInfoRow('Ano:', widget.vehicle.year.toString()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ALA de Serviço
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.group,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ALA de Serviço',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAla,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: AppColors.textSecondary),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedAla = newValue;
                                  });
                                }
                              },
                              items: _alas.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Data e Hora (apenas informativa)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Data e Hora do Checklist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Container apenas informativo (não clicável)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy - HH:mm')
                                    .format(_currentDateTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Atual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'O checklist será registrado com a data e hora atuais',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão Iniciar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startChecklist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Iniciar Checklist',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16), // Espaçamento final menor
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
