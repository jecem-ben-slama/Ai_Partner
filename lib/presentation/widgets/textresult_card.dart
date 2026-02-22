import 'package:flutter/material.dart';

class TextResultCard extends StatelessWidget {
  final String text;
  const TextResultCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
