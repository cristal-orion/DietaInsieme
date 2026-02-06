import 'dart:io';
import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonaCard extends StatelessWidget {
  final Persona persona;
  final VoidCallback onDietaTap;
  final VoidCallback onDatiTap;

  const PersonaCard({
    super.key,
    required this.persona,
    required this.onDietaTap,
    required this.onDatiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBg,
                  radius: 24,
                  backgroundImage: persona.immagineProfilo != null &&
                          File(persona.immagineProfilo!).existsSync()
                      ? FileImage(File(persona.immagineProfilo!))
                      : null,
                  child: persona.immagineProfilo != null &&
                          File(persona.immagineProfilo!).existsSync()
                      ? null
                      : Text(
                          persona.nome.isNotEmpty ? persona.nome[0].toUpperCase() : '?',
                          style: GoogleFonts.fraunces(
                            fontSize: 24,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Text(
                  persona.nome,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    title: 'Dieta',
                    subtitle: persona.dietaAttiva != null ? 'Caricata' : 'Mancante',
                    icon: Icons.restaurant_menu_rounded,
                    isActive: persona.dietaAttiva != null,
                    onTap: onDietaTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    title: 'Dati',
                    subtitle: persona.bodygramAttivo != null 
                        ? '${persona.bodygramAttivo!.datiBase.peso} kg' 
                        : 'Mancanti',
                    icon: Icons.monitor_weight_rounded,
                    isActive: persona.bodygramAttivo != null,
                    onTap: onDatiTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _InfoBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Always allow tap to handle "empty" state feedback (e.g. SnackBars) if needed by parent
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgPrimary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.textPrimary : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.textSecondary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
