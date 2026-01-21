import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/pasto.dart';

class PastoTabSelector extends StatelessWidget {
  final TipoPasto selectedPasto;
  final Function(TipoPasto) onPastoChanged;
  
  const PastoTabSelector({
    required this.selectedPasto,
    required this.onPastoChanged,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(context, TipoPasto.pranzo, 'Pranzo', Icons.wb_sunny_outlined),
          _buildTab(context, TipoPasto.cena, 'Cena', Icons.nights_stay_outlined),
        ],
      ),
    );
  }
  
  Widget _buildTab(BuildContext context, TipoPasto pasto, String label, IconData icon) {
    final isSelected = selectedPasto == pasto;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onPastoChanged(pasto),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
