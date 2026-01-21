import 'package:flutter/material.dart';
import '../models/pasto_comune.dart';
import '../theme/app_theme.dart';

class AlimentiSeparatiSection extends StatelessWidget {
  final List<AlimentoSeparato> alimenti;
  
  const AlimentiSeparatiSection({
    required this.alimenti,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    if (alimenti.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_outline, color: Colors.orange.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'SEPARATI',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alimenti.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alimento = alimenti[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.orange.shade50,
                  child: Text(
                    alimento.persona[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Text(
                  alimento.nome,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  alimento.quantita,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
