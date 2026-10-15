import 'package:flutter/material.dart';

import '../theme.dart';

class CategoryThumb extends StatelessWidget {
  const CategoryThumb({
    super.key,
    required this.emoji,
    required this.index,
    this.imageUrl,
    this.size,
    this.height,
    this.emojiSize = 26,
    this.radius = 12,
  });

  final String emoji;
  final int index;
  final String? imageUrl;
  final double? size;
  final double? height;
  final double emojiSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final h = height ?? size;
    final box = Container(
      width: size,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: hueGradient(index),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
    );
    final url = imageUrl;
    if (url == null) return box;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: h,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => box,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : box,
        ),
      ),
    );
  }
}
