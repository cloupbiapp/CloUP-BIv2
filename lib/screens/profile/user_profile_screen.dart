import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  const UserProfileScreen({super.key, required this.userId, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _following = false;
  int _followers = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = context.read<AuthProvider>().currentUser?.uid;
    try {
      final p = await Supabase.instance.client.from('profiles').select().eq('id', widget.userId).maybeSingle();
      if (p != null) _followers = p['followers'] ?? 0;
      if (me != null && me != widget.userId) {
        final f = await Supabase.instance.client.from('follows').select().eq('follower_id', me).eq('following_id', widget.userId).maybeSingle();
        _following = f != null;
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _toggle() async {
    final me = context.read<AuthProvider>().currentUser?.uid;
    if (me == null || me == widget.userId) return;
    if (_following) {
      await Supabase.instance.client.from('follows').delete().eq('follower_id', me).eq('following_id', widget.userId);
      setState(() { _following = false; _followers--; });
    } else {
      await Supabase.instance.client.from('follows').insert({'follower_id': me, 'following_id': widget.userId});
      setState(() { _following = true; _followers++; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = context.read<AuthProvider>().currentUser?.uid == widget.userId;
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
          Text(widget.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('$_followers seguidores'),
          if (!isMe)
            ElevatedButton(onPressed: _toggle, child: Text(_following ? 'Siguiendo' : 'Seguir')),
        ],
      ),
    );
  }
}
