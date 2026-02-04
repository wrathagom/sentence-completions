import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/analytics_data.dart';

class WordCloudWidget extends StatelessWidget {
  final List<WordFrequency> words;
  final double minFontSize;
  final double maxFontSize;

  const WordCloudWidget({
    super.key,
    required this.words,
    this.minFontSize = 12,
    this.maxFontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
    ];

    final random = Random(42);
    const angles = [0.0, -0.12, 0.12, -0.25, 0.25];

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: words.map((word) {
                    final fontSize = minFontSize +
                        (maxFontSize - minFontSize) * word.normalizedSize;
                    final color = colors[random.nextInt(colors.length)];
                    final angle = word.normalizedSize > 0.75
                        ? 0.0
                        : angles[random.nextInt(angles.length)];

                    return Tooltip(
                      message: '${word.word}: ${word.count} ${word.count == 1 ? 'time' : 'times'}',
                      child: Transform.rotate(
                        angle: angle,
                        child: Text(
                          word.word,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: word.normalizedSize > 0.7
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
