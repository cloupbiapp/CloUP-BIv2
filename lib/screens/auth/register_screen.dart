import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(_email.text.trim(), _password.text, _username.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _username, decoration: const InputDecoration(labelText: 'Usuario')),
            const SizedBox(height: 12),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const CircularProgressIndicator() : const Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
