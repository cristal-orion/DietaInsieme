import 'package:flutter/material.dart';
import '../models/pasto_comune.dart';
import '../theme/app_theme.dart';

class AlimentiComuniSection extends StatelessWidget {
  final List<AlimentoComune> alimenti;
  final String nomePersona1;
  final String nomePersona2;
  
  const AlimentiComuniSection({
    required this.alimenti,
    required this.nomePersona1,
    required this.nomePersona2,
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'IN COMUNE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...alimenti.map((alimento) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alimento.nome,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (alimento.stessaQuantita)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alimento.quantitaPersona1,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!alimento.stessaQuantita) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantitaPill(context, nomePersona1, alimento.quantitaPersona1),
                      const SizedBox(width: 12),
                      _buildQuantitaPill(context, nomePersona2, alimento.quantitaPersona2),
                    ],
                  ),
                ],
              ],
            ),
          ),
        )),
      ],
    );
  }
  
  Widget _buildQuantitaPill(BuildContext context, String nome, String quantita) {
    final iniziala = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                iniziala,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                quantita,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
