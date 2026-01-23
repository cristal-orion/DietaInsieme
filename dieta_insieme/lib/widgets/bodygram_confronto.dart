import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bodygram.dart';
import '../theme/app_theme.dart';

/// Widget che mostra un confronto tra due bodygram in una tabella.
class BodygramConfronto extends StatelessWidget {
  final Bodygram precedente;
  final Bodygram attuale;

  const BodygramConfronto({
    super.key,
    required this.precedente,
    required this.attuale,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'it_IT');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'CONFRONTO BODYGRAM',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Header con date
            Row(
              children: [
                const SizedBox(width: 100), // Spazio per le etichette
                Expanded(
                  child: Center(
                    child: Text(
                      dateFormat.format(precedente.dataEsame),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 60), // Spazio per variazione
                Expanded(
                  child: Center(
                    child: Text(
                      dateFormat.format(attuale.dataEsame),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Righe confronto
            _buildConfrontoRow(
              context,
              'Peso',
              precedente.peso,
              attuale.peso,
              'kg',
              Icons.scale_outlined,
            ),
            _buildConfrontoRow(
              context,
              'BMI',
              precedente.bmi,
              attuale.bmi,
              '',
              Icons.calculate_outlined,
              invertiColori: true,
            ),
            _buildConfrontoRow(
              context,
              'Massa Grassa',
              precedente.massaGrassaPercentuale,
              attuale.massaGrassaPercentuale,
              '%',
              Icons.opacity_outlined,
              invertiColori: true,
            ),
            _buildConfrontoRow(
              context,
              'Massa Muscolare',
              precedente.componenti.massaMuscolarePercentuale,
              attuale.componenti.massaMuscolarePercentuale,
              '%',
              Icons.fitness_center_outlined,
            ),
            _buildConfrontoRow(
              context,
              'Massa Magra',
              precedente.componenti.massaMagra,
              attuale.componenti.massaMagra,
              'kg',
              Icons.accessibility_new_outlined,
            ),
            _buildConfrontoRow(
              context,
              'Acqua Totale',
              precedente.fluidi.acquaTotale,
              attuale.fluidi.acquaTotale,
              'Lt',
              Icons.water_drop_outlined,
            ),
            _buildConfrontoRow(
              context,
              'Idratazione',
              precedente.idratazioneTissutale,
              attuale.idratazioneTissutale,
              '%',
              Icons.water_outlined,
            ),
            _buildConfrontoRow(
              context,
              'Metab. Basale',
              precedente.metabolismoBasale,
              attuale.metabolismoBasale,
              'kcal',
              Icons.local_fire_department_outlined,
            ),
            _buildConfrontoRow(
              context,
              'Angolo di Fase',
              precedente.angoloFase,
              attuale.angoloFase,
              '',
              Icons.speed_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfrontoRow(
    BuildContext context,
    String label,
    double valorePrecedente,
    double valoreAttuale,
    String unit,
    IconData icon, {
    bool invertiColori = false,
  }) {
    final diff = valoreAttuale - valorePrecedente;
    final isPositive = diff > 0;
    final isNeutral = diff.abs() < 0.1;

    Color coloreDiff;
    IconData iconDiff;

    if (isNeutral) {
      coloreDiff = AppColors.textMuted;
      iconDiff = Icons.remove;
    } else if (invertiColori) {
      // Per grasso/BMI: diminuzione = bene (verde), aumento = attenzione (arancione)
      coloreDiff = isPositive ? Colors.orange : AppColors.primary;
      iconDiff = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      // Per muscolo/acqua: aumento può essere neutro, diminuzione attenzione
      coloreDiff = isPositive ? AppColors.primary : Colors.orange;
      iconDiff = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${valorePrecedente.toStringAsFixed(1)}$unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          ),
          // Variazione
          SizedBox(
            width: 60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: coloreDiff.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconDiff, size: 12, color: coloreDiff),
                    const SizedBox(width: 2),
                    Text(
                      diff.abs().toStringAsFixed(1),
                      style: TextStyle(
                        color: coloreDiff,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${valoreAttuale.toStringAsFixed(1)}$unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget per selezionare un bodygram dallo storico
class BodygramStoricoSelector extends StatelessWidget {
  final List<Bodygram> storico;
  final Bodygram? attivo;
  final Bodygram? selezionato;
  final Function(Bodygram?) onSeleziona;

  const BodygramStoricoSelector({
    super.key,
    required this.storico,
    this.attivo,
    this.selezionato,
    required this.onSeleziona,
  });

  @override
  Widget build(BuildContext context) {
    if (storico.isEmpty) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMM yy', 'it_IT');

    // Ordina storico per data (più recente prima)
    final storicoOrdinato = List<Bodygram>.from(storico)
      ..sort((a, b) => b.dataEsame.compareTo(a.dataEsame));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'STORICO BODYGRAM',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
                const Spacer(),
                if (selezionato != null)
                  TextButton(
                    onPressed: () => onSeleziona(null),
                    child: const Text('Deseleziona'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tocca un esame passato per confrontarlo con quello attuale',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storicoOrdinato.length,
                itemBuilder: (context, index) {
                  final bodygram = storicoOrdinato[index];
                  final isSelected = selezionato?.id == bodygram.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          onSeleziona(null);
                        } else {
                          onSeleziona(bodygram);
                        }
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dateFormat.format(bodygram.dataEsame),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${bodygram.peso.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
