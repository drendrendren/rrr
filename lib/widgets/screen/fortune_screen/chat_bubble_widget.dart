import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Widget child;

  const ChatBubble({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4A148C),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF311B92).withOpacity(0.6),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: const Color(0xFF7C4DFF), width: 1),
      ),
      child: child,
    );
  }
}
