import 'package:flutter/material.dart';
import '../models/checklist_category.dart';
import '../models/checklist_item.dart';
import '../utils/app_colors.dart';

class CategoryDetailScreen extends StatefulWidget {
  final ChecklistCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late ChecklistCategory _category;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
  }

  void _updateItem(ChecklistItem updatedItem) {
    setState(() {
      final index = _category.items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _category.items[index] = updatedItem;
      }
    });
  }

  void _showItemDialog(ChecklistItem item) {
    final observationController = TextEditingController(text: item.observations ?? '');
    bool isChecked = item.isChecked;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              
              // Status do item
              Row(
                children: [
                  const Text('Status: '),
                  Switch(
                    value: isChecked,
                    onChanged: (value) {
                      setDialogState(() {
                        isChecked = value;
                      });
                    },
                  ),
                  Text(isChecked ? 'OK' : 'Pendente'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Campo de observações
              TextField(
                controller: observationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedItem = item.copyWith(
                  isChecked: isChecked,
                  observations: observationController.text.trim().isEmpty 
                      ? null 
                      : observationController.text.trim(),
                  checkedAt: isChecked ? DateTime.now() : null,
                );
                _updateItem(updatedItem);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_category.title),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, _category);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com progresso
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _category.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso: ${_category.completedCount}/${_category.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_category.completionPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _category.completionPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          
          // Lista de itens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _category.items.length,
              itemBuilder: (context, index) {
                final item = _category.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      item.isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: item.isChecked ? AppColors.successGreen : AppColors.textSecondary,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.description),
                    trailing: item.observations != null 
                        ? const Icon(Icons.note, color: AppColors.primaryRed)
                        : null,
                    onTap: () => _showItemDialog(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}