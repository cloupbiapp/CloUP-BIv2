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
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _imageFile = file);
  }

  Future<String?> _upload(XFile file, String uid) async {
    final bytes = await file.readAsBytes();
    final path = 'posts/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Supabase.instance.client.storage.from('posts').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
    return Supabase.instance.client.storage.from('posts').getPublicUrl(path);
  }

  Future<void> _publish() async {
    if (_controller.text.trim().isEmpty && _imageFile == null) return;
    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      String? url;
      if (_imageFile != null) url = await _upload(_imageFile!, user.uid);
      await Supabase.instance.client.from('posts').insert({
        'user_id': user.uid,
        'username': user.username,
        'content': _controller.text.trim(),
        'image_url': url,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        actions: [TextButton(onPressed: _loading ? null : _publish, child: _loading ? const CircularProgressIndicator() : const Text('Publicar'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, maxLines: 5, decoration: const InputDecoration(hintText: 'Escribí algo...')),
            const SizedBox(height: 16),
            if (_imageFile != null) Image.file(File(_imageFile!.path), height: 200, fit: BoxFit.cover),
            OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Agregar foto')),
          ],
        ),
      ),
    );
  }
}
