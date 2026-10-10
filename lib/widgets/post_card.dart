import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post.content),
            ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${post.likes} me gusta', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
