import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _username, _bio;
  bool _loading = false;
  XFile? _photo;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().currentUser;
    _username = TextEditingController(text: u?.username ?? '');
    _bio = TextEditingController(text: u?.bio ?? '');
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      String? photoUrl;
      if (_photo != null) {
        final bytes = await _photo!.readAsBytes();
        final path = 'avatars/${user.uid}.jpg';
        await Supabase.instance.client.storage.from('avatars').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
        photoUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
      }
      await Supabase.instance.client.from('profiles').update({
        'username': _username.text.trim(),
        'bio': _bio.text.trim(),
        if (photoUrl != null) 'photo_url': photoUrl,
      }).eq('id', user.uid);
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
        title: const Text('Editar perfil'),
        actions: [TextButton(onPressed: _loading ? null : _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: CircleAvatar(radius: 48, backgroundImage: _photo != null ? FileImage(File(_photo!.path)) : null, child: _photo == null ? const Icon(Icons.person, size: 48) : null)),
          TextButton(onPressed: () async {
            final f = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (f != null) setState(() => _photo = f);
          }, child: const Text('Cambiar foto')),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Usuario')),
          TextField(controller: _bio, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
        ],
      ),
    );
  }
}
