import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/doctor_model.dart';
import '../../../services/doctor_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String doctorId;
  const ProfileScreen({super.key, required this.doctorId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _doctorService = DoctorService();

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<DoctorModel?>(
        stream: _doctorService.watchDoctorProfile(widget.doctorId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          final doctor = snap.data;
          if (doctor == null) {
            return const EmptyStateWidget(message: 'Không tìm thấy hồ sơ');
          }
          return _buildProfile(doctor);
        },
      ),
    );
  }

  Widget _buildProfile(DoctorModel doctor) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(doctor)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoSection(doctor),
              const SizedBox(height: 14),
              _buildAvailabilitySection(doctor),
              const SizedBox(height: 14),
              _buildBioSection(doctor),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đăng xuất',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(DoctorModel doctor) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFB5D4F4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(doctor.fullName),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFF0C447C)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(doctor.fullName,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text('${doctor.specialty} · ${doctor.clinicName}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Divider(height: 0),
        ],
      ),
    );
  }

  Widget _buildInfoSection(DoctorModel doctor) {
    return AppCard(
      child: Column(
        children: [
          _SectionTitle(
            title: 'Thông tin cá nhân',
            action: 'Chỉnh sửa',
            onAction: () => _showEditDialog(doctor),
          ),
          _FieldRow(label: 'Họ tên', value: doctor.fullName),
          _FieldRow(label: 'Chuyên khoa', value: doctor.specialty),
          _FieldRow(label: 'Phòng khám', value: doctor.clinicName),
          _FieldRow(label: 'Địa chỉ', value: doctor.address, isLast: false),
          _FieldRow(
            label: 'Giờ làm việc',
            value: '${doctor.workStartTime} – ${doctor.workEndTime}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(DoctorModel doctor) {
    return AppCard(
      child: Column(
        children: [
          const _SectionTitle(title: 'Trạng thái'),
          _ToggleRow(
            label: 'Sẵn sàng nhận bệnh nhân',
            subLabel: 'isAvailable',
            value: doctor.isAvailable,
            onChanged: (v) =>
                _doctorService.toggleAvailability(widget.doctorId, v),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(DoctorModel doctor) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Bio'),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              doctor.bio.isEmpty ? 'Chưa có bio' : doctor.bio,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(DoctorModel doctor) {
    final fullNameCtrl = TextEditingController(text: doctor.fullName);
    final specialtyCtrl = TextEditingController(text: doctor.specialty);
    final clinicCtrl = TextEditingController(text: doctor.clinicName);
    final bioCtrl = TextEditingController(text: doctor.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chỉnh sửa hồ sơ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên')),
            const SizedBox(height: 10),
            TextField(
                controller: specialtyCtrl,
                decoration: const InputDecoration(labelText: 'Chuyên khoa')),
            const SizedBox(height: 10),
            TextField(
                controller: clinicCtrl,
                decoration: const InputDecoration(labelText: 'Phòng khám')),
            const SizedBox(height: 10),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _doctorService.updateProfile(
                    widget.doctorId,
                    fullName: fullNameCtrl.text,
                    specialty: specialtyCtrl.text,
                    clinicName: clinicCtrl.text,
                    bio: bioCtrl.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _FieldRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              Text(subLabel,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}
