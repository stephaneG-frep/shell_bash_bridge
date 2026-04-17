import 'package:flutter/material.dart';

import '../../../core/utils/enums.dart';

class CommandCategory {
  const CommandCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.shellTypes,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<ShellType> shellTypes;
}
