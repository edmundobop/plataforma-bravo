import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final int completedItems;
  final int totalItems;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.completedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso Geral',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.successGreen 
                      : AppColors.secondaryYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    color: isCompleted ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.successGreen : AppColors.secondaryYellow,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedItems de $totalItems itens',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (isCompleted)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Completo',
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}