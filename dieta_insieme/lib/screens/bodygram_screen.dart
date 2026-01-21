import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bodygram.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/progress_indicator_bar.dart';

class BodygramScreen extends StatelessWidget {
  final Bodygram bodygram;

  const BodygramScreen({
    super.key,
    required this.bodygram,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'it_IT');

    return Scaffold(
      appBar: AppBar(
        title: Text(bodygram.persona),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Esame del ${dateFormatter.format(bodygram.dataEsame)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${bodygram.eta} anni • ${bodygram.sesso}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Section 1: Dati Base
            StatCard(
              title: 'Dati Base',
              icon: Icons.monitor_weight_outlined,
              children: [
                StatRow(
                  icon: Icons.scale_outlined,
                  label: 'Peso',
                  value: bodygram.datiBase.peso.toStringAsFixed(1),
                  unit: 'kg',
                ),
                Divider(color: Colors.grey.shade100),
                StatRow(
                  icon: Icons.height_outlined,
                  label: 'Altezza',
                  value: (bodygram.datiBase.altezza * 100).toStringAsFixed(0),
                  unit: 'cm',
                ),
                Divider(color: Colors.grey.shade100),
                StatRow(
                  icon: Icons.calculate_outlined,
                  label: 'BMI',
                  value: bodygram.datiBase.bmi.toStringAsFixed(1),
                  trailing: _buildBmiBadge(context, bodygram.datiBase.bmi),
                ),
              ],
            ),

            // Section 2: Composizione Corporea
            StatCard(
              title: 'Composizione',
              icon: Icons.pie_chart_outline,
              children: [
                _buildFatMassBar(context),
                Divider(color: Colors.grey.shade100, height: 24),
                ProgressIndicatorBar(
                  label: 'Massa Magra',
                  value: bodygram.componenti.massaMagraPercentuale,
                  valueText: '${bodygram.componenti.massaMagra.toStringAsFixed(1)} kg',
                  color: AppColors.primary,
                ),
              ],
            ),

            // Section 3: Fluidi
            StatCard(
              title: 'Fluidi',
              icon: Icons.water_drop_outlined,
              children: [
                StatRow(
                  icon: Icons.water_outlined,
                  label: 'Acqua Totale',
                  value: bodygram.fluidi.acquaTotale.toStringAsFixed(1),
                  unit: 'Lt',
                  trailing: Text(
                    '${bodygram.fluidi.acquaTotalePercentuale.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Divider(color: Colors.grey.shade100),
                StatRow(
                  icon: Icons.opacity_outlined,
                  label: 'Idratazione',
                  value: bodygram.idratazioneTissutale.toStringAsFixed(1),
                  unit: '%',
                  trailing: _buildHydrationBadge(context),
                ),
              ],
            ),

            // Section 4: Metabolismo
            StatCard(
              title: 'Metabolismo',
              icon: Icons.bolt_outlined,
              children: [
                StatRow(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Metabolismo Basale',
                  value: bodygram.metabolismoBasale.toStringAsFixed(0),
                  unit: 'kcal',
                ),
                Divider(color: Colors.grey.shade100),
                StatRow(
                  icon: Icons.speed_outlined,
                  label: 'Angolo di Fase',
                  value: bodygram.angoloFase.toStringAsFixed(1),
                  unit: '°',
                  trailing: _buildPhaseAngleBadge(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiBadge(BuildContext context, double bmi) {
    Color color;
    String label;

    if (bmi < 18.5) {
      color = Colors.blue;
      label = 'Sottopeso';
    } else if (bmi < 25) {
      color = AppColors.primary;
      label = 'Normale';
    } else if (bmi < 30) {
      color = Colors.orange;
      label = 'Sovrappeso';
    } else {
      color = Colors.red;
      label = 'Obeso';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFatMassBar(BuildContext context) {
    // Logic: warning if > 25 (men) or > 32 (women)
    final isMale = bodygram.sesso.toLowerCase().startsWith('m');
    final threshold = isMale ? 25.0 : 32.0;
    final isWarning = bodygram.massaGrassaPercentuale > threshold;

    return ProgressIndicatorBar(
      label: 'Massa Grassa',
      value: bodygram.massaGrassaPercentuale,
      valueText: '${bodygram.massaGrassa.toStringAsFixed(1)} kg',
      color: isWarning ? Colors.orange : AppColors.primary,
      isWarning: isWarning,
      badge: isWarning ? 'Attenzione' : 'Ottimo',
    );
  }

  Widget? _buildHydrationBadge(BuildContext context) {
    // Badge if hydration is between 70-76%
    if (bodygram.idratazioneTissutale >= 70 && bodygram.idratazioneTissutale <= 76) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.green),
      );
    }
    return null;
  }

  Widget? _buildPhaseAngleBadge(BuildContext context) {
    // Badge if phase angle is between 5-7
    if (bodygram.angoloFase >= 5 && bodygram.angoloFase <= 7) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.green),
      );
    }
    return null;
  }
}
