import 'package:flutter/material.dart';
import '../../../../models/medical_record_model.dart';
import '../../../../services/medical_record_service.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';

class MedicalRecordDetailScreen extends StatefulWidget {
  final String appointmentId;
  final String patientName;
  final String date;

  const MedicalRecordDetailScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.date,
  });

  @override
  State<MedicalRecordDetailScreen> createState() => _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<MedicalRecordDetailScreen> {
  final _medicalRecordService = MedicalRecordService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hồ sơ ngày ${widget.date}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<MedicalRecordModel?>(
        future: _medicalRecordService.getMedicalRecordByAppointmentId(widget.appointmentId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError || snap.data == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin bệnh án cho lần khám này.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          final record = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPatientInfo(),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Bệnh án',
                children: [
                  _infoRow('Chẩn đoán', record.diagnosis.isEmpty ? 'Không có' : record.diagnosis),
                  _infoRow('Triệu chứng', record.symptoms.isEmpty ? 'Không có' : record.symptoms),
                  _infoRow('Hướng điều trị', record.treatment.isEmpty ? 'Không có' : record.treatment, isLast: true),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Bảo hiểm y tế',
                children: [
                  _infoRow('Áp dụng BHYT', record.isCover ? 'Có' : 'Không'),
                  if (record.isCover)
                    _infoRow('Mức hưởng', '${record.percentCover}%', isLast: true)
                  else
                    const SizedBox(height: 1),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Đơn thuốc',
                children: [
                  if (record.prescriptions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Không có đơn thuốc', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    )
                  else
                    ...record.prescriptions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: i == record.prescriptions.length - 1 ? null : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${i + 1}. ${p.medicineName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Số lượng: ${p.quantity} viên/lọ/ống', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text('Sử dụng trong ${p.duration} ngày', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            if (p.note.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text('Cách dùng: ${p.note}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      );
                    }),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_shared, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Khám ngày: ${widget.date}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
          ...children
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
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
