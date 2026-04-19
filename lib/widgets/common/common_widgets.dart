import 'package:flutter/material.dart';
import '../../theme.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;
  final double fontSize;

  const AvatarWidget({
    super.key,
    required this.initials,
    required this.colorIndex,
    this.size = 38,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.avatarBg(colorIndex),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.avatarText(colorIndex),
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const StatusBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  factory StatusBadge.done() => const StatusBadge(
        label: 'Đã khám',
        bg: AppColors.successLight,
        fg: AppColors.success,
      );

  factory StatusBadge.waiting() => const StatusBadge(
        label: 'Chờ khám',
        bg: AppColors.warningLight,
        fg: AppColors.warning,
      );

  factory StatusBadge.inProgress() => const StatusBadge(
        label: 'Đang khám',
        bg: AppColors.primaryLight,
        fg: AppColors.primary,
      );

  factory StatusBadge.cancelled() => const StatusBadge(
        label: 'Đã hủy',
        bg: AppColors.dangerLight,
        fg: AppColors.danger,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
