import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class AssistenteInputBar extends StatefulWidget {
  final Function(String, Uint8List?) onInvia;
  final VoidCallback onRicetta;
  final VoidCallback onAlternative;
  final bool isLoading;
  
  const AssistenteInputBar({
    required this.onInvia,
    required this.onRicetta,
    required this.onAlternative,
    this.isLoading = false,
    super.key,
  });
  
  @override
  State<AssistenteInputBar> createState() => _AssistenteInputBarState();
}

class _AssistenteInputBarState extends State<AssistenteInputBar> {
  final _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _selectedImage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image Preview
        if (_selectedImage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_selectedImage!, height: 60, width: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Immagine allegata',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedImage = null),
                ),
              ],
            ),
          ),

        // Quick actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.restaurant_menu, size: 18),
                label: const Text('Ricetta'),
                onPressed: widget.isLoading ? null : widget.onRicetta,
                backgroundColor: AppColors.primaryBg,
                labelStyle: TextStyle(color: AppColors.primary),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Sostituzioni'),
                onPressed: widget.isLoading ? null : widget.onAlternative,
                backgroundColor: AppColors.primaryBg,
                labelStyle: TextStyle(color: AppColors.primary),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              ),
            ],
          ),
        ),
        
        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: widget.isLoading ? null : _pickImage,
                color: AppColors.primary,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Chiedi all\'assistente...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.bgPrimary,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) => _onSubmit(text),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _onSubmit(_controller.text),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Scatta foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imagePicker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() => _selectedImage = bytes);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Scegli dalla galleria'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() => _selectedImage = bytes);
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore immagine: $e')),
      );
    }
  }

  void _onSubmit(String text) {
    if ((text.trim().isEmpty && _selectedImage == null) || widget.isLoading) return;
    widget.onInvia(text, _selectedImage);
    _controller.clear();
    setState(() => _selectedImage = null);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
