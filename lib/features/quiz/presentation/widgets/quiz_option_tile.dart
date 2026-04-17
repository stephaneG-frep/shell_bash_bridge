import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.correct,
    required this.showState,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool showState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (showState && correct) color = Colors.green.withValues(alpha: 0.2);
    if (showState && selected && !correct) color = Colors.red.withValues(alpha: 0.2);

    return Card(
      color: color,
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}
