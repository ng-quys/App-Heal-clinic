import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import 'widgets/patient_components.dart';
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
              stream: _appointmentService.watchAllAppointments(widget.doctorId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return const Center(
                    child: Text('Đã xảy ra lỗi khi tải dữ liệu', style: TextStyle(color: AppColors.danger)),
                  );
                }
                final allAppts = snap.data ?? [];
                return _buildPatientList(allAppts);
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

  Widget _buildPatientList(List<AppointmentModel> allAppts) {
    final todayAppts = allAppts.toList();

    return TabBarView(
      controller: _tabCtrl,
      children: [
        AllPatientsTab(
          doctorId: widget.doctorId,
          query: _query,
          allAppts: allAppts, // Tất cả uses allAppts (all dates)
          onTap: (patientId, patientName) => _openDetail(patientId, patientName),
        ),
        TodayPatientsTab(
          appts: todayAppts, // Hôm nay uses todayAppts
          onTap: (patientId, patientName) => _openDetail(patientId, patientName),
        ),
        QueuePatientsTab(
          appts: todayAppts.where((a) => // Hàng chờ uses todayAppts filtered
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.inProgress ||
              a.status == AppointmentStatus.pending).toList(),
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

