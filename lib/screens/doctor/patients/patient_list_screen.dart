import 'package:flutter/material.dart';
import '../../../models/patient_model.dart';
import '../../../models/appointment_model.dart';
import '../../../repositories/patient_repository.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  final String doctorId;
  const PatientListScreen({super.key, required this.doctorId});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _patientRepo = PatientRepository();
  final _appointmentService = AppointmentService();
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _appointmentService.watchTodayAppointments(widget.doctorId),
              builder: (context, snap) {
                final appts = snap.data ?? [];
                return _buildPatientList(appts);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bệnh nhân',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bệnh nhân...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Hôm nay'),
              Tab(text: 'Hàng chờ'),
            ],
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(List<AppointmentModel> appts) {
    return TabBarView(
      controller: _tabCtrl,
      children: [
        _AllPatientsTab(
          doctorId: widget.doctorId,
          query: _query,
          allAppts: appts,
          onTap: (patientId, patientName) => _openDetail(patientId, patientName),
        ),
        _TodayPatientsTab(
          appts: appts,
          onTap: (patientId, patientName) => _openDetail(patientId, patientName),
        ),
        _QueuePatientsTab(
          appts: appts.where((a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.inProgress).toList(),
          onTap: (patientId, patientName) => _openDetail(patientId, patientName),
        ),
      ],
    );
  }

  void _openDetail(String patientId, String patientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(
          patientId: patientId,
          doctorId: widget.doctorId,
          patientName: patientName,
        ),
      ),
    );
  }
}

class _AllPatientsTab extends StatelessWidget {
  final String doctorId;
  final String query;
  final List<AppointmentModel> allAppts;
  final Function(String, String) onTap;

  const _AllPatientsTab({
    required this.doctorId,
    required this.query,
    required this.allAppts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uniquePatients = <String, AppointmentModel>{};
    for (final a in allAppts) {
      uniquePatients.putIfAbsent(a.patientId, () => a);
    }
    final filtered = uniquePatients.values
        .where((a) =>
            query.isEmpty ||
            a.patientName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
          message: 'Chưa có bệnh nhân', icon: Icons.person_search_outlined);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, i) {
        final appt = filtered[i];
        return _PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == filtered.length - 1,
          onTap: () => onTap(appt.patientId, appt.patientName),
        );
      },
    );
  }
}

class _TodayPatientsTab extends StatelessWidget {
  final List<AppointmentModel> appts;
  final Function(String, String) onTap;

  const _TodayPatientsTab({required this.appts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return const EmptyStateWidget(message: 'Không có lịch hôm nay');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, i) {
        final appt = appts[i];
        return _PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == appts.length - 1,
          onTap: () => onTap(appt.patientId, appt.patientName),
          time: '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}',
        );
      },
    );
  }
}

class _QueuePatientsTab extends StatelessWidget {
  final List<AppointmentModel> appts;
  final Function(String, String) onTap;

  const _QueuePatientsTab({required this.appts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return const EmptyStateWidget(message: 'Hàng chờ trống');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, i) {
        final appt = appts[i];
        return _PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == appts.length - 1,
          onTap: () => onTap(appt.patientId, appt.patientName),
          queueNumber: appt.queueNumber,
        );
      },
    );
  }
}

class _PatientTile extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String specialty;
  final AppointmentStatus status;
  final int colorIndex;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final String? time;
  final int? queueNumber;

  const _PatientTile({
    required this.patientId,
    required this.patientName,
    required this.specialty,
    required this.status,
    required this.colorIndex,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.time,
    this.queueNumber,
  });

  @override
  Widget build(BuildContext context) {
    final initials = () {
      final parts = patientName.trim().split(' ');
      if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      return patientName.isNotEmpty ? patientName[0].toUpperCase() : '?';
    }();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                AvatarWidget(initials: initials, colorIndex: colorIndex),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      Text(specialty,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (time != null)
                      Text(time!,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                    if (queueNumber != null)
                      Text('Số $queueNumber',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    _badge(status),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(AppointmentStatus status) {
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
