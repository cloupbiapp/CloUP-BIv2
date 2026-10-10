import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select('*, profiles(photo_url)')
          .order('created_at', ascending: false)
          .limit(30);
      _posts = (data as List).map((row) {
        final profile = row['profiles'];
        return PostModel(
          id: row['id']?.toString() ?? '',
          userId: row['user_id'] ?? '',
          username: row['username'] ?? 'usuario',
          userPhotoUrl: profile is Map ? profile['photo_url'] : null,
          content: row['content'] ?? '',
          imageUrl: row['image_url'],
          likes: row['likes'] ?? 0,
          createdAt: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CloUP BI', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? const Center(child: Text('Tu feed está vacío'))
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (_, i) => PostCard(post: _posts[i]),
                  ),
      ),
    );
  }
}
