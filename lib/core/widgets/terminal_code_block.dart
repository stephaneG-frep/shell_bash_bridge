import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class TerminalCodeBlock extends StatelessWidget {
  const TerminalCodeBlock({
    super.key,
    required this.code,
    this.accent,
  });

  final String code;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: (accent ?? AppColors.secondaryAccent).withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\$ ', style: AppTextStyles.mono.copyWith(color: accent ?? AppColors.secondaryAccent)),
          Expanded(child: Text(code, style: AppTextStyles.mono)),
        ],
      ),
    );
  }
}
