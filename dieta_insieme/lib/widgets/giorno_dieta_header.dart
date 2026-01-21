import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GiornoDietaHeader extends StatelessWidget {
  final int giornoCorrente;
  final DateTime? dataInizio;
  final VoidCallback onModifica;
  
  const GiornoDietaHeader({
    required this.giornoCorrente,
    this.dataInizio,
    required this.onModifica,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final oggi = DateTime.now();
    final giornoSettimana = _giornoSettimanaItaliano(oggi.weekday);
    final dataFormattata = '${oggi.day}/${oggi.month}/${oggi.year}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 $giornoSettimana $dataFormattata',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giorno $giornoCorrente della dieta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onModifica,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifica'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  String _giornoSettimanaItaliano(int weekday) {
    const giorni = ['', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica'];
    return giorni[weekday];
  }
}
