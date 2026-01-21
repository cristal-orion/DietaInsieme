import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressIndicatorBar extends StatelessWidget {
  final String label;
  final double value;        // percentuale (0-100)
  final String valueText;    // testo descrittivo valore assoluto (es. "41.2 kg")
  final Color color;
  final String? badge;       // eventuale badge (es. "+16.1%")
  final bool isWarning;

  const ProgressIndicatorBar({
    super.key,
    required this.label,
    required this.value,
    required this.valueText,
    required this.color,
    this.badge,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.bgPrimary,
              color: color,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                valueText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isWarning ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isWarning ? Colors.orange.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isWarning ? Colors.orange.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
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
