import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';
import '../../../../utils/format_utils.dart';
import '../examination_screen.dart';

class CurrentPatientCard extends StatelessWidget {
  final AppointmentModel appt;
  final AppointmentService appointmentService;

  const CurrentPatientCard({super.key, required this.appt, required this.appointmentService});

  @override
  Widget build(BuildContext context) {
    final initials = FormatUtils.getInitials(appt.patientName);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đang khám',
              style: TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.patientName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    Text(
                        'Số ${appt.queueNumber ?? '-'} · ${appt.reason}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Bắt đầu',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  Text(
                    FormatUtils.formatTime(appt.scheduledAt),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AnimatedPress(
                  onTap: () =>
                      appointmentService.cancelAppointment(appt.appointmentId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Bỏ qua', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AnimatedPress(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExaminationScreen(appointment: appt))
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    alignment: Alignment.center,
                    child: const Text('Mở hồ sơ khám',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyCurrentCard extends StatelessWidget {
  final bool hasWaiting;
  final AppointmentModel? nextAppt;
  final AppointmentService appointmentService;
  final String doctorId;

  const EmptyCurrentCard({
    super.key,
    required this.hasWaiting,
    required this.nextAppt,
    required this.appointmentService,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.co_present_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            hasWaiting
                ? 'Đã sẵn sàng cho ca tiếp theo'
                : 'Không có bệnh nhân đang chờ',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
            if (hasWaiting && nextAppt != null)
              AnimatedPress(
                onTap: () async {
                  await appointmentService.markInProgress(nextAppt!.appointmentId, doctorId: doctorId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gọi bệnh nhân vào khám!')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientSoft,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Text('Gọi vào', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
        ],
      ),
    );
  }
}

class QueueWaitingRow extends StatelessWidget {
  final AppointmentModel appt;
  final VoidCallback onSkip;

  const QueueWaitingRow({
    super.key,
    required this.appt,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradientSoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Center(
              child: Text('${appt.queueNumber ?? '-'}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.patientName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${appt.reason} - ${FormatUtils.formatTime(appt.scheduledAt)}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          QueueStatusBadgeWaiting(),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class QueueStatusBadgeWaiting extends StatelessWidget {
  const QueueStatusBadgeWaiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Chờ',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warning)),
    );
  }
}
