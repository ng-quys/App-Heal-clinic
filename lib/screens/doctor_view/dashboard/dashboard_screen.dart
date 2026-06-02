import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../services/doctor_service.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';
import '../patients/patient_list_screen.dart';
import '../appointments/appointment_screen.dart';
import '../queue/queue_screen.dart';
import 'profile_screen.dart';
import 'widgets/dashboard_components.dart';
import '../../../utils/format_utils.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();
  
  String? _userId;
  String? _doctorId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('token');
    if (uid != null) {
      _userId = uid;
      final doctor = await _doctorService.getDoctorProfile(uid);
      if (doctor != null) {
        setState(() {
          _doctorId = doctor.doctorId;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userId == null || _doctorId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 16),
              const Text("Không tìm thấy thông tin bác sĩ!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screens = [
      _DashboardTab(
        doctorService: _doctorService,
        appointmentService: _appointmentService,
        userId: _userId!,
        doctorId: _doctorId!,
      ),
      PatientListScreen(doctorId: _doctorId!),
      AppointmentScreen(doctorId: _doctorId!),
      ProfileScreen(userId: _userId!, doctorId: _doctorId!),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'Trang chủ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded), label: 'Bệnh nhân'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: 'Lịch khám'),
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
  final String userId;
  final String doctorId;

  const _DashboardTab({
    required this.doctorService,
    required this.appointmentService,
    required this.userId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<DoctorModel?>(
        stream: doctorService.watchDoctorProfile(userId),
        builder: (context, doctorSnap) {
          if (doctorSnap.hasError) {
            return const Center(child: Text('Lỗi khi tải thông tin bác sĩ', style: TextStyle(color: AppColors.danger)));
          }
          final doctor = doctorSnap.data;
          return StreamBuilder<List<AppointmentModel>>(
            stream: appointmentService.watchTodayAppointments(doctorId),
            builder: (context, apptSnap) {
              if (apptSnap.hasError) {
                return const Center(child: Text('Lỗi khi tải lịch khám', style: TextStyle(color: AppColors.danger)));
              }
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
                        SectionHeader(
                          title: 'Hàng chờ hôm nay',
                          actionLabel: 'Xem tất cả',
                          onAction: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QueueScreen(doctorId: doctorId),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildQueuePreview(appointments),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Lịch khám hôm nay'),
                        const SizedBox(height: 10),
                        _buildAppointmentPreview(appointments),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Lịch làm việc sắp tới (7 ngày)'),
                        const SizedBox(height: 10),
                        _buildWeeklySchedule(),
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
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doctor != null ? 'Bs. ${doctor.fullName}' : 'Đang tải...',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            doctor != null ? doctor.specialty : '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
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
      childAspectRatio: 1.35,
      children: [
        StatCard(
          value: '${summary['total']}',
          label: 'Lịch hôm nay',
          icon: Icons.calendar_today_outlined,
          isHighlighted: true,
        ),
        StatCard(
          value: '${summary['waiting']}',
          label: 'Hàng chờ',
          icon: Icons.access_time_outlined,
        ),
        StatCard(
          value: '${summary['done']}',
          label: 'Hoàn thành',
          icon: Icons.check_circle_outline_rounded,
        ),
        StatCard(
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
          return DashboardQueueRow(appt: appt, isLast: isLast);
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
          return DashboardAppointmentRow(appt: appt, isLast: i == preview.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    return FutureBuilder<List<AppointmentModel>>(
      future: appointmentService.getUpcomingAppointments(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Lỗi tải lịch sắp tới', style: TextStyle(color: AppColors.danger));
        }
        
        final upcoming = snapshot.data ?? [];
        if (upcoming.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(16),
            child: const Text('Không có lịch hẹn trong 7 ngày tới',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          );
        }

        // Group by Date
        final Map<String, int> dailyCounts = {};
        for (var appt in upcoming) {
          final dateStr = FormatUtils.formatDate(appt.scheduledAt);
          dailyCounts[dateStr] = (dailyCounts[dateStr] ?? 0) + 1;
        }

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dailyCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${entry.value} ca khám',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
