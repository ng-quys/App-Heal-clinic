import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';

class DoctorCalendar extends StatelessWidget {
  final int currentMonth;
  final int currentYear;
  final DateTime selectedDate;
  final Set<int> daysWithAppointments;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime) onDateSelected;

  const DoctorCalendar({
    super.key,
    required this.currentMonth,
    required this.currentYear,
    required this.selectedDate,
    required this.daysWithAppointments,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPrevMonth,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size(28, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  '${monthNames[currentMonth]}, $currentYear',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size(28, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          _buildDayHeaders(),
          _buildDayGrid(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((d) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDayGrid() {
    final firstDay = DateTime(currentYear, currentMonth, 1);
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: startWeekday + daysInMonth,
        itemBuilder: (context, i) {
          if (i < startWeekday) return const SizedBox();
          final day = i - startWeekday + 1;
          final date = DateTime(currentYear, currentMonth, day);
          final isToday = today.year == date.year &&
              today.month == date.month &&
              today.day == date.day;
          final isSelected = selectedDate.year == date.year &&
              selectedDate.month == date.month &&
              selectedDate.day == date.day;
          final hasAppt = daysWithAppointments.contains(day);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected
                        ? null
                        : isToday
                            ? AppColors.primaryLight
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday || isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (hasAppt && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppointmentTimeRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;
  final Function(AppointmentStatus) onStatusChange;

  const AppointmentTimeRow({
    super.key,
    required this.appt,
    required this.isLast,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}';
    final endTime = appt.scheduledAt.add(const Duration(minutes: 30));
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    final dotColor = _dotColor(appt.status);

    return AnimatedPress(
      onTap: () => _showStatusMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(timeStr,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: dotColor)),
                Container(
                    width: 2,
                    height: 18,
                    color: dotColor.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(vertical: 2)),
                Text(endStr,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 12),
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
            _statusBadge(appt.status),
          ],
        ),
      ),
    );
  }

  Color _dotColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return AppColors.success;
      case AppointmentStatus.inProgress:
        return AppColors.primary;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
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

  void _showStatusMenu(BuildContext context) {
    if (appt.status == AppointmentStatus.done ||
        appt.status == AppointmentStatus.cancelled) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(appt.patientName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (appt.status == AppointmentStatus.pending) ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                title: const Text('Xác nhận lịch hẹn'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.confirmed);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                title: const Text('Từ chối lịch hẹn'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.cancelled);
                },
              ),
            ],
            if (appt.status == AppointmentStatus.confirmed || appt.status == AppointmentStatus.waiting) ...[
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                title: const Text('Bắt đầu khám'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.inProgress);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                title: const Text('Hủy lịch'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.cancelled);
                },
              ),
            ],
            if (appt.status == AppointmentStatus.inProgress) ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                title: const Text('Đánh dấu hoàn thành'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.done);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                title: const Text('Hủy lịch'),
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(AppointmentStatus.cancelled);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
