import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String user;
  final String text;
  final String time;

  const Comment({
    Key? key,
    required this.user,
    required this.text,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),

          // User, time
          Row(
            children: [
              Text(
                user,
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
              const Text(
                '.',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
