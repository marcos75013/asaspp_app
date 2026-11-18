import 'package:flutter/material.dart';

import '../config/api_config.dart';

class MemberAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  const MemberAvatar({
    super.key,
    this.url,
    required this.name,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim();
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: radius,
      foregroundImage: imageUrl == null || imageUrl.isEmpty
          ? null
          : NetworkImage(const ApiConfig().resolveUrl(imageUrl)),
      onForegroundImageError: imageUrl == null || imageUrl.isEmpty
          ? null
          : (error, stack) {},
      child: initials.isEmpty
          ? const Icon(Icons.person_outline)
          : Text(initials),
    );
  }
}
