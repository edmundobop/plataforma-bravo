import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_checklist.dart';
import '../models/checklist_category.dart';
import '../utils/app_colors.dart';
import '../widgets/category_card.dart';
import '../widgets/progress_indicator_widget.dart';
import 'category_detail_screen.dart';
import 'signature_screen.dart';

class ChecklistScreen extends StatefulWidget {
  final VehicleChecklist checklist;

  const ChecklistScreen({
    super.key,
    required this.checklist,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late VehicleChecklist _checklist;
  final TextEditingController _observationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checklist = widget.checklist;
    _observationsController.text = _checklist.generalObservations ?? '';
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  void _updateCategory(ChecklistCategory updatedCategory) {
    setState(() {
      final index = _checklist.categories.indexWhere((cat) => cat.id == updatedCategory.id);
      if (index != -1) {
        _checklist.categories[index] = updatedCategory;
      }
    });
  }

  void _updateGeneralObservations(String observations) {
    setState(() {
      _checklist = _checklist.copyWith(generalObservations: observations);
    });
  }

  void _goToSignature() {
    if (_checklist.overallCompletionPercentage < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos os itens antes de finalizar'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignatureScreen(checklist: _checklist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist CBMGO'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_checklist.completedItems}/${_checklist.totalItems}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header compacto com informações essenciais
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Informações da viatura em uma linha compacta
                Row(
                  children: [
                    const Icon(
                      Icons.fire_truck,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_checklist.vehicleType} - ${_checklist.vehicleId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _checklist.vehiclePlate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Responsável e data em uma linha compacta
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_checklist.responsibleRank} ${_checklist.responsibleName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM - HH:mm').format(_checklist.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Indicador de progresso compacto
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Progresso:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _checklist.overallCompletionPercentage / 100,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _checklist.overallCompletionPercentage == 100 
                              ? Colors.green 
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_checklist.overallCompletionPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de categorias com mais espaço
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checklist.categories.length,
              itemBuilder: (context, index) {
                final category = _checklist.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryCard(
                    category: category,
                    onTap: () async {
                      final updatedCategory = await Navigator.push<ChecklistCategory>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailScreen(category: category),
                        ),
                      );
                      
                      if (updatedCategory != null) {
                        _updateCategory(updatedCategory);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // Observações gerais compactas
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Observações Gerais',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _observationsController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Digite observações gerais sobre o checklist...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryRed),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: _updateGeneralObservations,
                ),
              ],
            ),
          ),
          
          // Botão de finalizar compacto
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: _goToSignature,
              style: ElevatedButton.styleFrom(
                backgroundColor: _checklist.overallCompletionPercentage == 100 
                    ? AppColors.primaryRed 
                    : AppColors.textSecondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _checklist.overallCompletionPercentage == 100 
                        ? Icons.check_circle 
                        : Icons.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _checklist.overallCompletionPercentage == 100 
                        ? 'Finalizar Checklist' 
                        : 'Checklist Incompleto',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}