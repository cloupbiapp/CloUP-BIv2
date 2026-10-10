import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Iniciá sesión')));

    return Scaffold(
      appBar: AppBar(title: Text(user.username)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 46,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? const Icon(Icons.person, size: 48) : null,
            ),
            const SizedBox(height: 8),
            Text(user.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (user.bio != null && user.bio!.isNotEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(user.bio!)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [Text('${user.followers}', style: const TextStyle(fontWeight: FontWeight.bold)), const Text('seguidores')]),
                Column(children: [Text('${user.following}', style: const TextStyle(fontWeight: FontWeight.bold)), const Text('siguiendo')]),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: const Text('Editar perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
