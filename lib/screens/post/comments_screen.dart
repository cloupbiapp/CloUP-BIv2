import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postUsername;
  const CommentsScreen({super.key, required this.postId, required this.postUsername});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('comments')
          .select('*, profiles(username)')
          .eq('post_id', widget.postId)
          .order('created_at');
      _comments = List<Map<String, dynamic>>.from(data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('comments').insert({
      'post_id': widget.postId,
      'user_id': user.uid,
      'content': text,
    });
    _controller.clear();
    await _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comentarios · ${widget.postUsername}')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (_, i) {
                      final c = _comments[i];
                      final profile = c['profiles'];
                      final username = profile is Map ? profile['username'] ?? 'usuario' : 'usuario';
                      return ListTile(
                        title: Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c['content'] ?? ''),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Agregar un comentario...'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
