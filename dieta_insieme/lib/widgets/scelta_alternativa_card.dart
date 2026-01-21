import 'package:flutter/material.dart';
import '../models/pasto_comune.dart';
import '../theme/app_theme.dart';

class SceltaAlternativaCard extends StatelessWidget {
  final SceltaAlternative scelta;
  final String nomePersona1;
  final String nomePersona2;
  final Function(String) onSceltaEffettuata;
  
  const SceltaAlternativaCard({
    required this.scelta,
    required this.nomePersona1,
    required this.nomePersona2,
    required this.onSceltaEffettuata,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header categoria
            Row(
              children: [
                Icon(
                  _iconaCategoria(scelta.categoria),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  scelta.categoria,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Alternative comuni (selezionabili)
            if (scelta.alternativeComuni.isNotEmpty) ...[
              Text(
                'Scegliete una:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...scelta.alternativeComuni.map((alt) => RadioListTile<String>(
                title: Text(alt),
                value: alt,
                groupValue: scelta.sceltaEffettuata,
                onChanged: (value) {
                  if (value != null) onSceltaEffettuata(value);
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppColors.primary,
              )),
            ],
            
            // Separatore
            if (scelta.soloPersona1.isNotEmpty || scelta.soloPersona2.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
            ],
            
            // Solo persona 1
            if (scelta.soloPersona1.isNotEmpty) ...[
              Text(
                'Solo $nomePersona1:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                scelta.soloPersona1.map((a) => '${a.nome} ${a.quantita}').join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
            ],
            
            // Solo persona 2
            if (scelta.soloPersona2.isNotEmpty) ...[
              Text(
                'Solo $nomePersona2:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                scelta.soloPersona2.map((a) => '${a.nome} ${a.quantita}').join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _iconaCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'verdura': return Icons.eco;
      case 'proteina': return Icons.egg;
      case 'primo / carboidrati': return Icons.rice_bowl;
      case 'frutta': return Icons.apple;
      default: return Icons.restaurant;
    }
  }
}
