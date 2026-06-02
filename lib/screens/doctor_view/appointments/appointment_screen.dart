import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import 'widgets/appointment_components.dart';
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
  String _selectedStatus = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Chờ khám', 'Đang khám', 'Đã khám', 'Đã hủy'];

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
          DoctorCalendar(
            currentMonth: _currentMonth,
            currentYear: _currentYear,
            selectedDate: _selectedDate,
            daysWithAppointments: _daysWithAppointments,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          _buildStatusFilter(),
          const Divider(height: 0),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _appointmentService.watchAppointmentsByDate(
                  widget.doctorId, _selectedDate),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                if (snap.hasError) {
                  return const Center(
                    child: Text('Đã xảy ra lỗi khi tải dữ liệu', style: TextStyle(color: AppColors.danger)),
                  );
                }
                var appts = snap.data ?? [];
                
                // Filter by selected status
                if (_selectedStatus != 'Tất cả') {
                  appts = appts.where((a) => a.status.label == _selectedStatus).toList();
                }

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

  Widget _buildStatusFilter() {
    return Container(
      color: AppColors.surface,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = filter == _selectedStatus;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter, style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
              )),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = filter;
                  });
                }
              },
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
              return AppointmentTimeRow(
                appt: appt,
                isLast: i == appointments.length - 1,
                onStatusChange: (status) async {
                  if (status == AppointmentStatus.done) {
                    await _appointmentService.markAsDone(appt.appointmentId);
                  } else if (status == AppointmentStatus.inProgress) {
                    await _appointmentService.markInProgress(appt.appointmentId);
                  } else if (status == AppointmentStatus.cancelled) {
                    await _appointmentService.cancelAppointment(appt.appointmentId);
                  } else if (status == AppointmentStatus.confirmed) {
                    await _appointmentService.confirmAppointment(appt.appointmentId);
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

