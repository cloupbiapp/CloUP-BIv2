import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/user_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    try {
      final data = await Supabase.instance.client.from('profiles').select().ilike('username', '%$q%').limit(20);
      setState(() => _results = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          decoration: const InputDecoration(hintText: 'Buscar usuarios', prefixIcon: Icon(Icons.search)),
          onChanged: _doSearch,
        ),
      ),
      body: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (_, i) {
          final u = _results[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(u['username'] ?? 'usuario'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userId: u['id'], username: u['username'] ?? 'usuario'))),
          );
        },
      ),
    );
  }
}
