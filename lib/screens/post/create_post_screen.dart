import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _imageFile = file);
  }

  Future<String?> _uploadImage(XFile file, String userId) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = 'posts/$fileName';

    await Supabase.instance.client.storage.from('posts').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );
    return Supabase.instance.client.storage.from('posts').getPublicUrl(path);
  }

  Future<void> _publish() async {
    if (_controller.text.trim().isEmpty && _imageFile == null) return;
    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!, user.uid);
      }

      await Supabase.instance.client.from('posts').insert({
        'user_id': user.uid,
        'username': user.username,
        'content': _controller.text.trim(),
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _publish,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publicar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(hintText: 'Escribí un pie de foto...'),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              Image.file(File(_imageFile!.path), height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Agregar foto'),
            ),
          ],
        ),
      ),
    );
  }
}
