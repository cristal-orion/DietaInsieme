import 'package:flutter/material.dart';
import '../models/pasto.dart';
import '../theme/app_theme.dart';
import 'alimento_tile.dart';

class PastoCard extends StatelessWidget {
  final Pasto pasto;

  const PastoCard({
    super.key,
    required this.pasto,
  });

  Color _getHeaderColor(TipoPasto tipo) {
    switch (tipo) {
      case TipoPasto.colazione: return AppColors.colazione;
      case TipoPasto.spuntinoMattina: return AppColors.spuntino;
      case TipoPasto.pranzo: return AppColors.pranzo;
      case TipoPasto.merenda: return AppColors.merenda;
      case TipoPasto.cena: return AppColors.cena;
      case TipoPasto.spuntinoSera: return AppColors.spuntino; // Riutilizzo verde chiaro
      case TipoPasto.duranteGiornata: return AppColors.duranteGiornata;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _getHeaderColor(pasto.tipo);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: headerColor,
            child: Row(
              children: [
                Text(
                  pasto.tipoEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  pasto.tipoLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...pasto.alimenti.map((alimento) => AlimentoTile(alimento: alimento)),
          if (pasto.nota != null && pasto.nota!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pasto.nota!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
