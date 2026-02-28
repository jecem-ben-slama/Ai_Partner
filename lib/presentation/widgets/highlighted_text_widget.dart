import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String fullText;
  final int start;
  final int end;

  const HighlightedText({
    super.key,
    required this.fullText,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    if (end <= start || end > fullText.length) {
      return Text(fullText, style: _baseStyle(context));
    }

    return RichText(
      text: TextSpan(
        style: _baseStyle(context),
        children: [
          TextSpan(text: fullText.substring(0, start)),
          TextSpan(
            text: fullText.substring(start, end),
            style: TextStyle(
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.onPrimary, // High contrast
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: fullText.substring(end)),
        ],
      ),
    );
  }

  TextStyle _baseStyle(BuildContext context) => TextStyle(
    fontSize: 19,
    height: 1.6,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
