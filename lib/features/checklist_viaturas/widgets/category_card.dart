import 'package:flutter/material.dart';
import '../models/checklist_category.dart';
import '../utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final ChecklistCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = category.isCompleted;
    final completionPercentage = category.completionPercentage;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? AppColors.successGreen : AppColors.dividerColor,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícone da categoria
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppColors.successGreen.withOpacity(0.1)
                          : AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      size: 32,
                      color: isCompleted ? AppColors.successGreen : AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Título e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? AppColors.successGreen : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status e seta
                  Column(
                    children: [
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'COMPLETO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso: ${category.completedCount}/${category.items.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${completionPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppColors.successGreen : AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: AppColors.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.successGreen : AppColors.primaryRed,
                    ),
                    minHeight: 6,
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