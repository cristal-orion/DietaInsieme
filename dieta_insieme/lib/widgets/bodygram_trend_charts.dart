import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/bodygram.dart';
import '../theme/app_theme.dart';

/// Widget che mostra l'andamento dei valori bodygram nel tempo.
/// Mostra un grafico combinato con peso, massa grassa, massa muscolare e BMI.
class BodygramTrendCharts extends StatefulWidget {
  final List<Bodygram> storico;
  final Bodygram? attivo;

  const BodygramTrendCharts({
    super.key,
    required this.storico,
    this.attivo,
  });

  @override
  State<BodygramTrendCharts> createState() => _BodygramTrendChartsState();
}

class _BodygramTrendChartsState extends State<BodygramTrendCharts> {
  // Quali linee mostrare
  bool _mostraPeso = true;
  bool _mostraMassaGrassa = true;
  bool _mostraMassaMuscolare = true;
  bool _mostraBMI = false;

  // Colori per le linee
  static const _colorePeso = Color(0xFF4CAF50); // Verde
  static const _coloreMassaGrassa = Color(0xFFFF9800); // Arancione
  static const _coloreMassaMuscolare = Color(0xFF2196F3); // Blu
  static const _coloreBMI = Color(0xFF9C27B0); // Viola

  /// Combina attivo + storico e ordina per data
  List<Bodygram> get _tuttiOrdinati {
    final tutti = <Bodygram>[...widget.storico];
    if (widget.attivo != null) {
      // Evita duplicati
      if (!tutti.any((b) => b.id == widget.attivo!.id)) {
        tutti.add(widget.attivo!);
      }
    }
    tutti.sort((a, b) => a.dataEsame.compareTo(b.dataEsame));
    return tutti;
  }

  @override
  Widget build(BuildContext context) {
    final bodygrams = _tuttiOrdinati;

    // 0 bodygram: non mostrare nulla
    if (bodygrams.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1 bodygram: placeholder
    if (bodygrams.length == 1) {
      return _buildPlaceholder(context);
    }

    // 2+ bodygram: mostra grafico
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
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'ANDAMENTO BODYGRAM',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _buildChart(context, bodygrams),
            ),
            const SizedBox(height: 12),
            _buildSummaryTable(context, bodygrams),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'Un solo esame bodygram',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Carica il prossimo bodygram per vedere l\'andamento nel tempo',
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

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          context,
          'Peso (kg)',
          _colorePeso,
          _mostraPeso,
          (v) => setState(() => _mostraPeso = v),
        ),
        _buildLegendItem(
          context,
          'Grasso %',
          _coloreMassaGrassa,
          _mostraMassaGrassa,
          (v) => setState(() => _mostraMassaGrassa = v),
        ),
        _buildLegendItem(
          context,
          'Muscolo %',
          _coloreMassaMuscolare,
          _mostraMassaMuscolare,
          (v) => setState(() => _mostraMassaMuscolare = v),
        ),
        _buildLegendItem(
          context,
          'BMI',
          _coloreBMI,
          _mostraBMI,
          (v) => setState(() => _mostraBMI = v),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    bool isActive,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<Bodygram> bodygrams) {
    final dateFormat = DateFormat('MMM yy', 'it_IT');
    final primaData = bodygrams.first.dataEsame;

    // Calcola range Y per ciascuna metrica
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    if (_mostraPeso) {
      for (final b in bodygrams) {
        if (b.peso < minY) minY = b.peso;
        if (b.peso > maxY) maxY = b.peso;
      }
    }
    if (_mostraMassaGrassa) {
      for (final b in bodygrams) {
        if (b.massaGrassaPercentuale < minY) minY = b.massaGrassaPercentuale;
        if (b.massaGrassaPercentuale > maxY) maxY = b.massaGrassaPercentuale;
      }
    }
    if (_mostraMassaMuscolare) {
      for (final b in bodygrams) {
        if (b.componenti.massaMuscolarePercentuale < minY) {
          minY = b.componenti.massaMuscolarePercentuale;
        }
        if (b.componenti.massaMuscolarePercentuale > maxY) {
          maxY = b.componenti.massaMuscolarePercentuale;
        }
      }
    }
    if (_mostraBMI) {
      for (final b in bodygrams) {
        if (b.bmi < minY) minY = b.bmi;
        if (b.bmi > maxY) maxY = b.bmi;
      }
    }

    // Fallback se nessuna metrica selezionata
    if (minY == double.infinity) {
      minY = 0;
      maxY = 100;
    }

    final range = maxY - minY;
    final padding = range > 0 ? range * 0.15 : 5.0;

    // Crea le linee
    final lineBars = <LineChartBarData>[];

    if (_mostraPeso) {
      lineBars.add(_createLineData(
        bodygrams,
        (b) => b.peso,
        _colorePeso,
        primaData,
      ));
    }
    if (_mostraMassaGrassa) {
      lineBars.add(_createLineData(
        bodygrams,
        (b) => b.massaGrassaPercentuale,
        _coloreMassaGrassa,
        primaData,
      ));
    }
    if (_mostraMassaMuscolare) {
      lineBars.add(_createLineData(
        bodygrams,
        (b) => b.componenti.massaMuscolarePercentuale,
        _coloreMassaMuscolare,
        primaData,
      ));
    }
    if (_mostraBMI) {
      lineBars.add(_createLineData(
        bodygrams,
        (b) => b.bmi,
        _coloreBMI,
        primaData,
      ));
    }

    if (lineBars.isEmpty) {
      return Center(
        child: Text(
          'Seleziona almeno una metrica',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 20 ? 10 : (range > 5 ? 5 : 2),
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= bodygrams.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dateFormat.format(bodygrams[index].dataEsame),
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
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
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: lineBars,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            fitInsideHorizontally: true,
            getTooltipItems: (touchedSpots) {
              if (touchedSpots.isEmpty) return [];
              // Prendi la data dal primo spot
              final index = touchedSpots.first.x.toInt();
              if (index < 0 || index >= bodygrams.length) return [];

              final bodygram = bodygrams[index];
              final dateStr = DateFormat('d MMM yyyy', 'it_IT').format(bodygram.dataEsame);

              return touchedSpots.asMap().entries.map((entry) {
                final spot = entry.value;
                final isFirst = entry.key == 0;

                String label = '';
                if (spot.bar.color == _colorePeso) {
                  label = 'Peso: ${spot.y.toStringAsFixed(1)} kg';
                } else if (spot.bar.color == _coloreMassaGrassa) {
                  label = 'Grasso: ${spot.y.toStringAsFixed(1)}%';
                } else if (spot.bar.color == _coloreMassaMuscolare) {
                  label = 'Muscolo: ${spot.y.toStringAsFixed(1)}%';
                } else if (spot.bar.color == _coloreBMI) {
                  label = 'BMI: ${spot.y.toStringAsFixed(1)}';
                }

                return LineTooltipItem(
                  isFirst ? '$dateStr\n$label' : label,
                  TextStyle(
                    color: spot.bar.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _createLineData(
    List<Bodygram> bodygrams,
    double Function(Bodygram) getValue,
    Color color,
    DateTime primaData,
  ) {
    final spots = <FlSpot>[];
    for (int i = 0; i < bodygrams.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(bodygrams[i])));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildSummaryTable(BuildContext context, List<Bodygram> bodygrams) {
    final primo = bodygrams.first;
    final ultimo = bodygrams.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variazione dal primo all\'ultimo esame:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildVariazioneItem(
                context,
                'Peso',
                primo.peso,
                ultimo.peso,
                'kg',
                _colorePeso,
                invertiColori: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVariazioneItem(
                context,
                'Grasso',
                primo.massaGrassaPercentuale,
                ultimo.massaGrassaPercentuale,
                '%',
                _coloreMassaGrassa,
                invertiColori: true, // meno grasso = meglio
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildVariazioneItem(
                context,
                'Muscolo',
                primo.componenti.massaMuscolarePercentuale,
                ultimo.componenti.massaMuscolarePercentuale,
                '%',
                _coloreMassaMuscolare,
                invertiColori: false, // piu muscolo = meglio
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVariazioneItem(
                context,
                'BMI',
                primo.bmi,
                ultimo.bmi,
                '',
                _coloreBMI,
                invertiColori: true, // meno BMI = meglio (generalmente)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariazioneItem(
    BuildContext context,
    String label,
    double valorePrimo,
    double valoreUltimo,
    String unit,
    Color color, {
    bool invertiColori = false,
  }) {
    final diff = valoreUltimo - valorePrimo;
    final isPositive = diff > 0;
    final isNeutral = diff.abs() < 0.1;

    Color coloreDiff;
    if (isNeutral) {
      coloreDiff = AppColors.textMuted;
    } else if (invertiColori) {
      // Per grasso/BMI: diminuzione = verde, aumento = rosso
      coloreDiff = isPositive ? Colors.orange : AppColors.primary;
    } else {
      // Per peso/muscolo: aumento = arancione, diminuzione = verde
      coloreDiff = isPositive ? Colors.orange : AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${valorePrimo.toStringAsFixed(1)}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted),
              Text(
                '${valoreUltimo.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: coloreDiff.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: coloreDiff,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
