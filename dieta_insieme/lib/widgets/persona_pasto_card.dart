import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/persona.dart';
import '../models/pasto.dart';
import '../models/alimento.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PersonaPastoCard extends StatelessWidget {
  final Persona persona;
  final TipoPasto tipoPasto;
  final int giorno;
  final VoidCallback onTap;

  const PersonaPastoCard({
    super.key,
    required this.persona,
    required this.tipoPasto,
    required this.giorno,
    required this.onTap,
  });

  void _pickProfileImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scatta foto'),
              onTap: () {
                Navigator.pop(ctx);
                _selectImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Scegli dalla galleria'),
              onTap: () {
                Navigator.pop(ctx);
                _selectImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (picked != null) {
      final file = File(picked.path);
      if (context.mounted) {
        await Provider.of<AppState>(context, listen: false)
            .updateImmagineProfilo(persona.id, file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recupera il pasto corrente dalla dieta
    final pasto = persona.dietaAttiva?.getGiorno(giorno)?.getPasto(tipoPasto);
    final hasPasto = pasto != null && pasto.alimenti.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con Nome
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickProfileImage(context),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: persona.immagineProfilo != null &&
                                  File(persona.immagineProfilo!).existsSync()
                              ? FileImage(File(persona.immagineProfilo!))
                              : null,
                          child: persona.immagineProfilo != null &&
                                  File(persona.immagineProfilo!).existsSync()
                              ? null
                              : Text(
                                  persona.nome.isNotEmpty
                                      ? persona.nome[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    persona.nome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Contenuto del pasto
              if (hasPasto)
                ...pasto!.alimenti.map((alimento) => _buildAlimentoRow(context, alimento))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Nessun alimento previsto per ${tipoPasto.label.toLowerCase()}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Giorno $giorno • ${tipoPasto.label}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlimentoRow(BuildContext context, Alimento alimento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: alimento.nome,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (alimento.quantita != null)
                    TextSpan(
                      text: ' ${alimento.quantita}',
                      style: TextStyle(color: Colors.grey[700]),
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
