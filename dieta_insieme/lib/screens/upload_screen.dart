import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../models/dieta.dart';
import '../models/bodygram.dart';
import '../models/persona.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isUploading = false;
  String? _fileName;
  Uint8List? _fileBytes;
  String _selectedType = 'dieta'; // 'dieta' or 'bodygram'
  String _selectedPerson = 'Michele'; // 'Michele' or 'Rossana'
  final GeminiService _geminiService = GeminiService();

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _fileBytes = result.files.single.bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nella selezione del file')),
      );
    }
  }

  Future<void> _processFile() async {
    if (_fileBytes == null) return;

    setState(() => _isUploading = true);

    try {
      if (_selectedType == 'dieta') {
        final json = await _geminiService.parseDietaPdf(_fileBytes!);
        // Ensure ID and Persona match the selection context if missing from parsing
        if (json['id'] == null) json['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        // Force the name to match the selected person to avoid mismatches
        json['persona'] = _selectedPerson; 
        
        final dieta = Dieta.fromJson(json);
        
        if (mounted) {
           // Aggiorna lo stato globale e salva su disco
           await Provider.of<AppState>(context, listen: false).updateDieta(_selectedPerson, dieta);
           
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dieta di $_selectedPerson caricata con successo!')),
          );
          Navigator.pop(context);
        }
      } else {
        final json = await _geminiService.parseBodygramPdf(_fileBytes!);
        // Ensure ID and Persona match if missing
        if (json['id'] == null) json['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        json['persona'] = _selectedPerson;

        final bodygram = Bodygram.fromJson(json);
        
        if (mounted) {
           // Aggiorna lo stato globale e salva su disco
           await Provider.of<AppState>(context, listen: false).updateBodygram(_selectedPerson, bodygram);
           
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bodygram di $_selectedPerson caricato con successo!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore analisi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get available people from AppState
    final appState = Provider.of<AppState>(context);
    final people = appState.persone;

    return Scaffold(
      appBar: AppBar(title: const Text('Carica Documento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPersonSelector(people),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 32),
            _buildFileDropZone(),
            const SizedBox(height: 32),
            if (_fileName != null) ...[
              ElevatedButton(
                onPressed: _isUploading ? null : _processFile,
                child: _isUploading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Text('ANALIZZA PDF'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonSelector(List<Persona> people) {
    if (people.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Nessuna persona trovata. Torna indietro e aggiungi una persona prima di caricare file.'),
        ),
      );
    }

    // Default to first person if selection is invalid
    if (!people.any((p) => p.nome == _selectedPerson) && people.isNotEmpty) {
       _selectedPerson = people.first.nome;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A chi appartiene questo file?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: people.map((p) => SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 2, // 2 columns approx
            child: _PersonCard(
              name: p.nome,
              isSelected: _selectedPerson == p.nome,
              onTap: () => setState(() => _selectedPerson = p.nome),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            title: 'Dieta',
            icon: Icons.restaurant_menu,
            isSelected: _selectedType == 'dieta',
            onTap: () => setState(() => _selectedType = 'dieta'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TypeCard(
            title: 'Dati Corporei',
            icon: Icons.accessibility_new,
            isSelected: _selectedType == 'bodygram',
            onTap: () => setState(() => _selectedType = 'bodygram'),
          ),
        ),
      ],
    );
  }

  Widget _buildFileDropZone() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _fileName != null ? Icons.check_circle : Icons.cloud_upload_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _fileName ?? 'Tocca per selezionare il PDF',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
