import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final Function()? onTap;
  final bool isLiked;

  const LikeButton({super.key, required this.onTap, required this.isLiked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_outline,
        color: isLiked ? Colors.red : Colors.white54,
      ),
    );
  }
}
