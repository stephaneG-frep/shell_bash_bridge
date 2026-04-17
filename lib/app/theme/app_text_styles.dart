import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 0.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    color: AppColors.primaryText,
    height: 1.5,
  );
}
