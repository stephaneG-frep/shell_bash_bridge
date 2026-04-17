import 'package:flutter/material.dart';

import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../core/widgets/shell_chip.dart';
import '../../domain/command_item.dart';

class CommandListItem extends StatelessWidget {
  const CommandListItem({
    super.key,
    required this.command,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final CommandItem command;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(command.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(command.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                ShellChip(shellType: command.shellType),
                const SizedBox(width: 8),
                DifficultyBadge(level: command.difficulty),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: onFavoriteTap,
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}
