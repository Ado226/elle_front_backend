import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CycleLegendWidget extends StatelessWidget {
  const CycleLegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          const Text(
            'Légende du Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: AppColors.periodColor,
                label: 'Période',
                icon: Icons.water_drop,
              ),
              _buildLegendItem(
                color: AppColors.fertileColor,
                label: 'Fertile',
                icon: Icons.eco,
              ),
              _buildLegendItem(
                color: AppColors.ovulationColor,
                label: 'Ovulation',
                icon: Icons.star,
              ),
              _buildLegendItem(
                color: AppColors.normalColor,
                label: 'Normal',
                icon: Icons.circle_outlined,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Additional info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Icône cœur = Rapport ajouté',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Bordure = Aujourd\'hui',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: _getIconColor(color),
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getIconColor(Color backgroundColor) {
    // Return contrasting color for icons
    if (backgroundColor == AppColors.normalColor) {
      return AppColors.textSecondary;
    } else if (backgroundColor == AppColors.ovulationColor) {
      return AppColors.textPrimary;
    } else {
      return AppColors.textLight;
    }
  }
}