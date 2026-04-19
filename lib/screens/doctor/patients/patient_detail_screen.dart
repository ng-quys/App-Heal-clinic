import 'package:flutter/material.dart';
import '../../../models/patient_model.dart';
import '../../../models/appointment_model.dart';
import '../../../repositories/patient_repository.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';
import '../chat/chat_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _patientRepo = PatientRepository();
  final _appointmentService = AppointmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bệnh nhân'),
        leading: const BackButton(),
      ),
      body: FutureBuilder<PatientModel?>(
        future: _patientRepo.getPatientById(widget.patientId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          final patient = snap.data;
          return FutureBuilder<List<AppointmentModel>>(
            future: _appointmentService.getPatientHistory(
                widget.doctorId, widget.patientId),
            builder: (context, apptSnap) {
              final appointments = apptSnap.data ?? [];
              return _buildContent(patient, appointments);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(PatientModel? patient, List<AppointmentModel> appointments) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHero(patient),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (patient != null) ...[
                _buildPersonalInfo(patient),
                const SizedBox(height: 14),
                _buildMedicalInfo(patient),
                const SizedBox(height: 14),
              ],
              _buildAppointmentHistory(appointments),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(PatientModel? patient) {
    final name = patient?.fullName ?? widget.patientName;
    final initials = patient?.initials ?? _initials(name);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            children: [
              AvatarWidget(
                initials: initials,
                colorIndex: widget.patientId.hashCode,
                size: 56,
                fontSize: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    if (patient != null)
                      Text(
                        '${patient.gender} · ${patient.age != null ? "${patient.age} tuổi" : ""}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 6),
                    StatusBadge.done(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.note_outlined, size: 16),
                  label: const Text('Ghi chú', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: const Text('Đặt lại', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        doctorId: widget.doctorId,
                        patientId: widget.patientId,
                        patientName: widget.patientName,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  label: const Text('Nhắn tin', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(PatientModel patient) {
    return AppCard(
      child: Column(
        children: [
          _cardHeader('Thông tin cá nhân'),
          _infoRow('Họ tên', patient.fullName),
          _infoRow('Giới tính', patient.gender),
          if (patient.dateOfBirth != null)
            _infoRow('Ngày sinh',
                '${patient.dateOfBirth!.day}/${patient.dateOfBirth!.month}/${patient.dateOfBirth!.year}'),
          _infoRow('Địa chỉ', patient.address),
          _infoRow('Liên hệ khẩn', patient.emergencyContactName,
              sub: patient.emergencyContactPhone, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo(PatientModel patient) {
    return AppCard(
      child: Column(
        children: [
          _cardHeader('Thông tin y tế'),
          _infoRow('Nhóm máu', patient.bloodType.isEmpty ? '—' : patient.bloodType),
          _infoRow(
              'Chiều cao',
              patient.height != null ? '${patient.height!.toStringAsFixed(0)} cm' : '—'),
          _infoRow(
              'Cân nặng',
              patient.weight != null ? '${patient.weight!.toStringAsFixed(0)} kg' : '—'),
          _infoRow(
              'Dị ứng',
              patient.allergies.isEmpty ? 'Không có' : patient.allergies.join(', ')),
          _infoRow(
              'Bệnh mãn tính',
              patient.chronicDiseases.isEmpty
                  ? 'Không có'
                  : patient.chronicDiseases.join(', '),
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistory(List<AppointmentModel> appointments) {
    return AppCard(
      child: Column(
        children: [
          _cardHeader('Lịch sử khám'),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có lịch sử khám',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )
          else
            ...appointments.asMap().entries.map((entry) {
              final i = entry.key;
              final appt = entry.value;
              final time =
                  '${appt.scheduledAt.day}/${appt.scheduledAt.month}/${appt.scheduledAt.year}';
              return _historyRow(appt.reason, time, appt.status, i == appointments.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _cardHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    );
  }

  Widget _infoRow(String label, String value, {String? sub, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (sub != null)
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(
      String reason, String date, AppointmentStatus status, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status == AppointmentStatus.done
                  ? AppColors.success
                  : AppColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return StatusBadge.done();
      case AppointmentStatus.cancelled:
        return StatusBadge.cancelled();
      default:
        return StatusBadge.waiting();
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
