import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../services/doctor_service.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';
import '../patients/patient_list_screen.dart';
import '../appointments/appointment_screen.dart';
import '../queue/queue_screen.dart';
import '../chat/chat_list_screen.dart';
import 'profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();
  
  // Tạm thời fix cứng UID nếu chưa login để không bị lỗi null pointer
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'temp_doctor_id';

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _DashboardTab(
        doctorService: _doctorService,
        appointmentService: _appointmentService,
        uid: _uid,
      ),
      PatientListScreen(doctorId: _uid),
      AppointmentScreen(doctorId: _uid),
      ChatListScreen(doctorId: _uid),
      ProfileScreen(doctorId: _uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'Trang chủ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded), label: 'Bệnh nhân'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: 'Lịch khám'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final DoctorService doctorService;
  final AppointmentService appointmentService;
  final String uid;

  const _DashboardTab({
    required this.doctorService,
    required this.appointmentService,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<DoctorModel?>(
        stream: doctorService.watchDoctorProfile(uid),
        builder: (context, doctorSnap) {
          final doctor = doctorSnap.data;
          return StreamBuilder<List<AppointmentModel>>(
            stream: appointmentService.watchTodayAppointments(uid),
            builder: (context, apptSnap) {
              final appointments = apptSnap.data ?? [];
              final summary = appointmentService.getTodaySummary(appointments);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, doctor)),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsGrid(summary),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Hàng chờ hôm nay'),
                        const SizedBox(height: 10),
                        _buildQueuePreview(appointments),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Lịch khám hôm nay'),
                        const SizedBox(height: 10),
                        _buildAppointmentPreview(appointments),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DoctorModel? doctor) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chào buổi sáng',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doctor != null ? 'Bs. ${doctor.fullName}' : 'Đang tải...',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
              ),
              if (doctor != null)
                _AvailabilityToggle(doctor: doctor, uid: uid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          value: '${summary['total']}',
          label: 'Lịch hôm nay',
          icon: Icons.calendar_today_outlined,
          isHighlighted: true,
        ),
        _StatCard(
          value: '${summary['waiting']}',
          label: 'Hàng chờ',
          icon: Icons.access_time_outlined,
        ),
        _StatCard(
          value: '${summary['done']}',
          label: 'Hoàn thành',
          icon: Icons.check_circle_outline_rounded,
        ),
        _StatCard(
          value: '${summary['inProgress']}',
          label: 'Đang khám',
          icon: Icons.medical_services_outlined,
        ),
      ],
    );
  }

  Widget _buildQueuePreview(List<AppointmentModel> appointments) {
    final queue = appointments
        .where((a) =>
            a.status == AppointmentStatus.confirmed ||
            a.status == AppointmentStatus.inProgress)
        .take(3)
        .toList();

    if (queue.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: const Text('Không có bệnh nhân trong hàng chờ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    return AppCard(
      child: Column(
        children: queue.asMap().entries.map((entry) {
          final i = entry.key;
          final appt = entry.value;
          final isLast = i == queue.length - 1;
          return _QueueRow(appt: appt, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentPreview(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: const Text('Không có lịch khám hôm nay',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }
    final preview = appointments.take(3).toList();
    return AppCard(
      child: Column(
        children: preview.asMap().entries.map((entry) {
          final i = entry.key;
          final appt = entry.value;
          return _AppointmentRow(appt: appt, isLast: i == preview.length - 1);
        }).toList(),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  final DoctorModel doctor;
  final String uid;

  const _AvailabilityToggle({required this.doctor, required this.uid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DoctorService().toggleAvailability(uid, !doctor.isAvailable);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: doctor.isAvailable ? AppColors.successLight : AppColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: doctor.isAvailable ? AppColors.success : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              doctor.isAvailable ? 'Sẵn sàng' : 'Nghỉ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: doctor.isAvailable ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isHighlighted;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHighlighted ? AppColors.primary : AppColors.surface;
    final fg = isHighlighted ? Colors.white : AppColors.textPrimary;
    final subFg = isHighlighted
        ? Colors.white.withOpacity(0.75)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted
            ? null
            : Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isHighlighted ? Colors.white : AppColors.primary, size: 20),
          const Spacer(),
          Text(value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: fg)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: subFg)),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;

  const _QueueRow({required this.appt, required this.isLast});

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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${appt.queueNumber ?? '-'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
              ),
            ),
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
          isActive
              ? StatusBadge.inProgress()
              : StatusBadge.waiting(),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;

  const _AppointmentRow({required this.appt, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          AvatarWidget(initials: _initials(appt.patientName), colorIndex: appt.patientId.hashCode),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
