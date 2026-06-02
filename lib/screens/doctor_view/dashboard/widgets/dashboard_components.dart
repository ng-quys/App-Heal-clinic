import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';
import '../../../../utils/format_utils.dart';


class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isHighlighted;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: () {
        // Có thể thêm tính năng chuyển hướng sau
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? null : AppColors.surface,
          gradient: isHighlighted ? AppColors.primaryGradientSoft : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: isHighlighted ? Colors.white : AppColors.primary, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: isHighlighted ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 12, color: isHighlighted ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardQueueRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;

  const DashboardQueueRow({super.key, required this.appt, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isActive = appt.status == AppointmentStatus.inProgress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : const Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${appt.queueNumber ?? '-'}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.patientName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text('${appt.reason} - ${FormatUtils.formatTime(appt.scheduledAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          isActive ? StatusBadge.inProgress() : StatusBadge.waiting(),
        ],
      ),
    );
  }
}

class DashboardAppointmentRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;

  const DashboardAppointmentRow({super.key, required this.appt, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final timeStr = FormatUtils.formatTime(appt.scheduledAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          AvatarWidget(initials: FormatUtils.getInitials(appt.patientName), colorIndex: appt.patientId.hashCode, size: 40, fontSize: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.patientName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(appt.reason,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              _statusBadge(appt.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return StatusBadge.done();
      case AppointmentStatus.inProgress:
        return StatusBadge.inProgress();
      case AppointmentStatus.cancelled:
        return StatusBadge.cancelled();
      default:
        return StatusBadge.waiting();
    }
  }
}
