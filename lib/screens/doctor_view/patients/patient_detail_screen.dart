import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/patient_model.dart';
import '../../../models/appointment_model.dart';
import '../../../repositories/patient_repository.dart';
import '../../../services/appointment_service.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../theme.dart';
import 'medical_record_detail_screen.dart';
import '../queue/examination_screen.dart';

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
  String _doctorNote = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorNote();
  }

  Future<void> _loadDoctorNote() async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'doctor_note_${widget.doctorId}_${widget.patientId}';
    setState(() {
      _doctorNote = prefs.getString(noteKey) ?? '';
    });
  }

  Future<void> _saveDoctorNote(String newNote) async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'doctor_note_${widget.doctorId}_${widget.patientId}';
    await prefs.setString(noteKey, newNote);
    setState(() {
      _doctorNote = newNote;
    });
  }

  Future<void> _clearDoctorNote() async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'doctor_note_${widget.doctorId}_${widget.patientId}';
    await prefs.remove(noteKey);
    setState(() {
      _doctorNote = '';
    });
  }

  void _showNoteBottomSheet() {
    final controller = TextEditingController(text: _doctorNote);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ghi chú cá nhân của Bác sĩ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ghi chú này được lưu trữ riêng tư trên thiết bị của bác sĩ và chỉ hiển thị với riêng bác sĩ.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú quan trọng về bệnh nhân (tiền sử dị ứng, thói quen ăn uống, lưu ý lâm sàng...)',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'LƯU GHI CHÚ',
              onPressed: () async {
                await _saveDoctorNote(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu ghi chú thành công!')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetNote() async {
    if (_doctorNote.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có ghi chú nào để xóa!')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú lâm sàng của bệnh nhân này? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _clearDoctorNote();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ghi chú thành công!')),
        );
      }
    }
  }

  Widget _buildDoctorNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Màu vàng nhạt sang trọng
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú của Bác sĩ (Cá nhân)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _doctorNote,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientModel?>(
      future: _patientRepo.getPatientById(widget.patientId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết bệnh nhân')),
            body: const LoadingWidget(),
          );
        }
        final patient = snap.data;
        return FutureBuilder<List<AppointmentModel>>(
          future: _appointmentService.getPatientHistory(
              widget.doctorId, widget.patientId),
          builder: (context, apptSnap) {
            final appointments = apptSnap.data ?? [];
            
            final today = DateTime.now();
            final todayAppts = appointments.where((a) => 
                a.scheduledAt.year == today.year && 
                a.scheduledAt.day == today.day && 
                a.scheduledAt.month == today.month).toList();

            final activeAppt = todayAppts.where((a) => a.status == AppointmentStatus.inProgress).firstOrNull ?? 
                         todayAppts.where((a) => a.status == AppointmentStatus.waiting || a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.pending).firstOrNull ??
                         todayAppts.firstOrNull;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết bệnh nhân'),
                leading: const BackButton(),
              ),
              body: _buildContent(patient, appointments, activeAppt),
              bottomNavigationBar: _buildBottomBar(activeAppt),
            );
          },
        );
      },
    );
  }

  Widget? _buildBottomBar(AppointmentModel? activeAppt) {
    if (activeAppt == null) return null;

    // Bệnh nhân đang chờ → "Gọi vào"
    if (activeAppt.status == AppointmentStatus.waiting ||
        activeAppt.status == AppointmentStatus.confirmed ||
        activeAppt.status == AppointmentStatus.pending) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              await _appointmentService.markInProgress(activeAppt.appointmentId);
              await _appointmentService.refreshQueue(widget.doctorId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gọi bệnh nhân vào khám!')),
                );
              }
            },
            icon: const Icon(Icons.campaign_rounded, color: Colors.white),
            label: const Text(
              'Gọi vào',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    // Bệnh nhân đang khám → "Mở hồ sơ khám"
    if (activeAppt.status == AppointmentStatus.inProgress) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExaminationScreen(appointment: activeAppt),
                ),
              );
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.folder_open_rounded, color: Colors.white),
            label: const Text(
              'Mở hồ sơ khám',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    // Bệnh nhân đã khám xong → "Xem hồ sơ khám"
    if (activeAppt.status == AppointmentStatus.done) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalRecordDetailScreen(
                    appointmentId: activeAppt.appointmentId,
                    patientName: activeAppt.patientName,
                    date: '${activeAppt.scheduledAt.day}/${activeAppt.scheduledAt.month}/${activeAppt.scheduledAt.year}',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.visibility_rounded, color: Colors.white),
            label: const Text(
              'Xem hồ sơ khám',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6), // Blue color for info
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildContent(PatientModel? patient, List<AppointmentModel> appointments, AppointmentModel? activeAppt) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHero(patient, activeAppt),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_doctorNote.isNotEmpty) ...[
                _buildDoctorNoteCard(),
                const SizedBox(height: 14),
              ],
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

  Widget _buildHero(PatientModel? patient, AppointmentModel? activeAppt) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Text('Bệnh nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    AvatarWidget(
                      initials: patient?.initials ?? _initials(patient?.fullName ?? widget.patientName),
                      colorIndex: widget.patientId.hashCode,
                      size: 64,
                      fontSize: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient?.fullName ?? widget.patientName,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          if (patient != null) ...[
                            const SizedBox(height: 4),
                            Text('${patient.gender} · ${patient.age != null ? "${patient.age} tuổi" : ""}',
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textSecondary)),
                          ],
                          const SizedBox(height: 8),
                          _statusBadge(activeAppt?.status ?? AppointmentStatus.done),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedPress(
                      onTap: _showNoteBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.softShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Text('Ghi chú', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedPress(
                      onTap: _confirmResetNote,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.softShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Text('Đặt lại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              return _historyRow(
                appt.appointmentId,
                widget.patientName,
                appt.reason,
                time,
                appt.status,
                i == appointments.length - 1,
              );
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
      String appointmentId, String patientName, String reason, String date, AppointmentStatus status, bool isLast) {
    return InkWell(
      onTap: () {
        if (status == AppointmentStatus.done) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalRecordDetailScreen(
            appointmentId: appointmentId,
            patientName: patientName,
            date: date,
          )));
        }
      },
      child: Container(
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
            if (status == AppointmentStatus.done)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
              )
          ],
        ),
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
