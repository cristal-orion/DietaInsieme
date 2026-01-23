import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/peso_giornaliero.dart';
import '../theme/app_theme.dart';

class PesoChart extends StatelessWidget {
  final List<PesoGiornaliero> pesi;
  final int giorniDaMostrare;

  const PesoChart({
    super.key,
    required this.pesi,
    this.giorniDaMostrare = 30,
  });

  @override
  Widget build(BuildContext context) {
    // Filtra e ordina i pesi
    final limite = DateTime.now().subtract(Duration(days: giorniDaMostrare));
    final pesiFiltrati = pesi
        .where((p) => p.data.isAfter(limite))
        .toList()
      ..sort((a, b) => a.data.compareTo(b.data));

    if (pesiFiltrati.isEmpty) {
      return _buildEmpty(context);
    }

    if (pesiFiltrati.length == 1) {
      return _buildSinglePoint(context, pesiFiltrati.first);
    }

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
                  Icons.show_chart,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'ANDAMENTO PESO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
                const Spacer(),
                Text(
                  'Ultimi $giorniDaMostrare giorni',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(context, pesiFiltrati),
            ),
            const SizedBox(height: 16),
            _buildSummary(context, pesiFiltrati),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'Nessun peso registrato',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Inserisci il peso di oggi per iniziare a tracciare i progressi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePoint(BuildContext context, PesoGiornaliero peso) {
    final dateFormat = DateFormat('d MMMM', 'it_IT');
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
                  Icons.show_chart,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'ANDAMENTO PESO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${peso.peso.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    dateFormat.format(peso.data),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continua a registrare il peso per vedere il grafico',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<PesoGiornaliero> pesiFiltrati) {
    // Calcola min e max per l'asse Y
    final pesiValues = pesiFiltrati.map((p) => p.peso).toList();
    final minPeso = pesiValues.reduce((a, b) => a < b ? a : b);
    final maxPeso = pesiValues.reduce((a, b) => a > b ? a : b);
    final range = maxPeso - minPeso;
    final padding = range > 0 ? range * 0.2 : 2.0;

    // Crea i punti del grafico
    final spots = <FlSpot>[];
    final primaData = pesiFiltrati.first.data;

    for (final peso in pesiFiltrati) {
      final giorni = peso.data.difference(primaData).inDays.toDouble();
      spots.add(FlSpot(giorni, peso.peso));
    }

    final dateFormat = DateFormat('d/M', 'it_IT');

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 5 ? 2 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calcolaIntervallo(pesiFiltrati.length),
              getTitlesWidget: (value, meta) {
                final data = primaData.add(Duration(days: value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dateFormat.format(data),
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: range > 5 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}kg',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minPeso - padding,
        maxY: maxPeso + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.primary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final data = primaData.add(Duration(days: spot.x.toInt()));
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} kg\n${dateFormat.format(data)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calcolaIntervallo(int numeroPunti) {
    if (numeroPunti <= 7) return 1;
    if (numeroPunti <= 14) return 2;
    if (numeroPunti <= 30) return 7;
    return 14;
  }

  Widget _buildSummary(BuildContext context, List<PesoGiornaliero> pesiFiltrati) {
    final pesoInizio = pesiFiltrati.first.peso;
    final pesoFine = pesiFiltrati.last.peso;
    final differenza = pesoFine - pesoInizio;

    final isPositive = differenza > 0;
    final isNeutral = differenza.abs() < 0.1;

    Color coloreDiff;
    if (isNeutral) {
      coloreDiff = AppColors.textMuted;
    } else if (isPositive) {
      coloreDiff = Colors.orange;
    } else {
      coloreDiff = AppColors.primary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(
          context,
          'Inizio',
          '${pesoInizio.toStringAsFixed(1)} kg',
          AppColors.textSecondary,
        ),
        _buildSummaryItem(
          context,
          'Attuale',
          '${pesoFine.toStringAsFixed(1)} kg',
          AppColors.primary,
        ),
        _buildSummaryItem(
          context,
          'Variazione',
          '${isPositive ? '+' : ''}${differenza.toStringAsFixed(1)} kg',
          coloreDiff,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
