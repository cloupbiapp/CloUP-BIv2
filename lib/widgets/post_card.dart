import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../screens/post/comments_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = false;
    _likes = widget.post.likes;
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final existing = await Supabase.instance.client
          .from('post_likes')
          .select()
          .eq('post_id', widget.post.id)
          .eq('user_id', uid)
          .maybeSingle();
      if (mounted) setState(() => _liked = existing != null);
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final was = _liked;
    setState(() {
      _liked = !was;
      _likes += was ? -1 : 1;
    });
    try {
      if (was) {
        await Supabase.instance.client.from('post_likes').delete().eq('post_id', widget.post.id).eq('user_id', uid);
        await Supabase.instance.client.rpc('decrement_likes', params: {'post_id': widget.post.id});
      } else {
        await Supabase.instance.client.from('post_likes').insert({'post_id': widget.post.id, 'user_id': uid});
        await Supabase.instance.client.rpc('increment_likes', params: {'post_id': widget.post.id});
      }
    } catch (_) {
      if (mounted) setState(() {
        _liked = was;
        _likes += was ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userPhotoUrl != null ? NetworkImage(post.userPhotoUrl!) : null,
              child: post.userPhotoUrl == null ? Text(post.username.isNotEmpty ? post.username[0].toUpperCase() : '?') : null,
            ),
            title: Text(post.username, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (post.content.isNotEmpty)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(post.content)),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            CachedNetworkImage(imageUrl: post.imageUrl!, height: 220, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_liked ? Icons.favorite : Icons.favorite_border, color: _liked ? Colors.red : null),
                  onPressed: _toggleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postId: post.id, postUsername: post.username))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text('$_likes me gusta', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
