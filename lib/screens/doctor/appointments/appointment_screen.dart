import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorId;
  const AppointmentScreen({super.key, required this.doctorId});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _appointmentService = AppointmentService();
  DateTime _selectedDate = DateTime.now();
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  Set<int> _daysWithAppointments = {};

  @override
  void initState() {
    super.initState();
    _loadMonthDates();
  }

  Future<void> _loadMonthDates() async {
    final dates = await _appointmentService.getMonthAppointmentDates(
        widget.doctorId, _currentYear, _currentMonth);
    setState(() {
      _daysWithAppointments = dates.map((d) => d.day).toSet();
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
    _loadMonthDates();
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
    _loadMonthDates();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          _buildCalendar(),
          const Divider(height: 0),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _appointmentService.watchAppointmentsByDate(
                  widget.doctorId, _selectedDate),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                final appts = snap.data ?? [];
                return _buildAppointmentList(appts);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text('Lịch khám',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildCalendar() {
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
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size(28, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  '${monthNames[_currentMonth]}, $_currentYear',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: _nextMonth,
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
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
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
          final date = DateTime(_currentYear, _currentMonth, day);
          final isToday = today.year == date.year &&
              today.month == date.month &&
              today.day == date.day;
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;
          final hasAppt = _daysWithAppointments.contains(day);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primaryLight
                            : Colors.transparent,
                    shape: BoxShape.circle,
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

  Widget _buildAppointmentList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const EmptyStateWidget(
          message: 'Không có lịch khám ngày này',
          icon: Icons.event_available_outlined);
    }

    final dateLabel =
        '${_selectedDate.weekday == 7 ? "Chủ nhật" : "Thứ ${_selectedDate.weekday + 1}"}, ${_selectedDate.day} tháng ${_selectedDate.month}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(dateLabel,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: appointments.asMap().entries.map((entry) {
              final i = entry.key;
              final appt = entry.value;
              return _AppointmentTimeRow(
                appt: appt,
                isLast: i == appointments.length - 1,
                onStatusChange: (status) async {
                  if (status == AppointmentStatus.done) {
                    await _appointmentService.markAsDone(appt.appointmentId);
                  } else if (status == AppointmentStatus.inProgress) {
                    await _appointmentService.markInProgress(appt.appointmentId);
                  } else if (status == AppointmentStatus.cancelled) {
                    await _appointmentService.cancelAppointment(appt.appointmentId);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AppointmentTimeRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;
  final Function(AppointmentStatus) onStatusChange;

  const _AppointmentTimeRow({
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

    return GestureDetector(
      onLongPress: () => _showStatusMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: dotColor.withOpacity(0.3),
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
        appt.status == AppointmentStatus.cancelled) return;

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
            ListTile(
              leading: const Icon(Icons.play_circle_outline,
                  color: AppColors.primary),
              title: const Text('Bắt đầu khám'),
              onTap: () {
                Navigator.pop(ctx);
                onStatusChange(AppointmentStatus.inProgress);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.success),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
