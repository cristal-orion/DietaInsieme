import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/peso_giornaliero.dart';
import '../theme/app_theme.dart';

class PesoInputCard extends StatefulWidget {
  final PesoGiornaliero? pesoOggi;
  final PesoGiornaliero? ultimoPeso;
  final Function(double peso, String? nota) onSalva;

  const PesoInputCard({
    super.key,
    this.pesoOggi,
    this.ultimoPeso,
    required this.onSalva,
  });

  @override
  State<PesoInputCard> createState() => _PesoInputCardState();
}

class _PesoInputCardState extends State<PesoInputCard> {
  final _pesoController = TextEditingController();
  final _notaController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void didUpdateWidget(PesoInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pesoOggi != widget.pesoOggi) {
      _initValues();
    }
  }

  void _initValues() {
    if (widget.pesoOggi != null) {
      _pesoController.text = widget.pesoOggi!.peso.toStringAsFixed(1);
      _notaController.text = widget.pesoOggi!.nota ?? '';
      _isEditing = false;
    } else {
      // Se c'è un ultimo peso, usa quello come default
      if (widget.ultimoPeso != null) {
        _pesoController.text = widget.ultimoPeso!.peso.toStringAsFixed(1);
      } else {
        _pesoController.text = '';
      }
      _notaController.text = '';
      _isEditing = true;
    }
  }

  void _salvaPeso() {
    final pesoText = _pesoController.text.replaceAll(',', '.');
    final peso = double.tryParse(pesoText);
    if (peso != null && peso > 0 && peso < 500) {
      final nota = _notaController.text.trim().isEmpty ? null : _notaController.text.trim();
      widget.onSalva(peso, nota);
      setState(() {
        _isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un peso valido')),
      );
    }
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM', 'it_IT');
    final hasPesoOggi = widget.pesoOggi != null;

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
                  Icons.scale_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'PESO DI OGGI',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
                const Spacer(),
                if (hasPesoOggi && !_isEditing)
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifica'),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isEditing && hasPesoOggi) ...[
              // Vista del peso salvato
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.pesoOggi!.peso.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'kg',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const Spacer(),
                  if (widget.ultimoPeso != null &&
                      widget.ultimoPeso!.id != widget.pesoOggi!.id) ...[
                    _buildDifferenza(
                      widget.pesoOggi!.peso - widget.ultimoPeso!.peso,
                    ),
                  ],
                ],
              ),
              if (widget.pesoOggi!.nota != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.pesoOggi!.nota!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ] else ...[
              // Form di inserimento
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _pesoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Peso (kg)',
                        hintText: 'es. 75.5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: 'kg',
                      ),
                      autofocus: !hasPesoOggi,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _notaController,
                      decoration: InputDecoration(
                        labelText: 'Nota (opzionale)',
                        hintText: 'es. a digiuno',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasPesoOggi)
                    TextButton(
                      onPressed: () {
                        _initValues();
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Annulla'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(hasPesoOggi ? 'Aggiorna' : 'Salva'),
                    onPressed: _salvaPeso,
                  ),
                ],
              ),
            ],
            // Info ultimo peso se diverso da oggi
            if (widget.ultimoPeso != null &&
                (widget.pesoOggi == null ||
                    widget.ultimoPeso!.id != widget.pesoOggi!.id)) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.history, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Ultimo peso: ${widget.ultimoPeso!.peso.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${dateFormat.format(widget.ultimoPeso!.data)})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifferenza(double diff) {
    final isPositive = diff > 0;
    final isNeutral = diff.abs() < 0.1;

    Color color;
    IconData icon;
    if (isNeutral) {
      color = AppColors.textMuted;
      icon = Icons.remove;
    } else if (isPositive) {
      color = Colors.orange;
      icon = Icons.arrow_upward;
    } else {
      color = AppColors.primary;
      icon = Icons.arrow_downward;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)} kg',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
