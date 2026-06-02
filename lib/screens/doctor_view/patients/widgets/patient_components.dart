import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';
import '../../../../utils/format_utils.dart';
import '../medical_record_detail_screen.dart';

class AllPatientsTab extends StatelessWidget {
  final String doctorId;
  final String query;
  final List<AppointmentModel> allAppts;
  final Function(String, String) onTap;

  const AllPatientsTab({
    super.key,
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
        return PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == filtered.length - 1,
          appointmentId: appt.appointmentId,
          scheduledAt: appt.scheduledAt,
          onTap: () => onTap(appt.patientId, appt.patientName),
        );
      },
    );
  }
}

class TodayPatientsTab extends StatelessWidget {
  final List<AppointmentModel> appts;
  final Function(String, String) onTap;

  const TodayPatientsTab({super.key, required this.appts, required this.onTap});

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
        return PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == appts.length - 1,
          appointmentId: appt.appointmentId,
          scheduledAt: appt.scheduledAt,
          onTap: () => onTap(appt.patientId, appt.patientName),
          time: FormatUtils.formatTime(appt.scheduledAt),
        );
      },
    );
  }
}

class QueuePatientsTab extends StatelessWidget {
  final List<AppointmentModel> appts;
  final Function(String, String) onTap;

  const QueuePatientsTab({super.key, required this.appts, required this.onTap});

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
        return PatientTile(
          patientId: appt.patientId,
          patientName: appt.patientName,
          specialty: appt.reason,
          status: appt.status,
          colorIndex: appt.patientId.hashCode,
          isFirst: i == 0,
          isLast: i == appts.length - 1,
          appointmentId: appt.appointmentId,
          scheduledAt: appt.scheduledAt,
          onTap: () => onTap(appt.patientId, appt.patientName),
          queueNumber: appt.queueNumber,
        );
      },
    );
  }
}

class PatientTile extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String specialty;
  final AppointmentStatus status;
  final int colorIndex;
  final bool isFirst;
  final bool isLast;
  final String appointmentId;
  final DateTime scheduledAt;
  final VoidCallback onTap;
  final String? time;
  final int? queueNumber;

  const PatientTile({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.specialty,
    required this.status,
    required this.colorIndex,
    required this.isFirst,
    required this.isLast,
    required this.appointmentId,
    required this.scheduledAt,
    required this.onTap,
    this.time,
    this.queueNumber,
  });

  @override
  Widget build(BuildContext context) {
    final initials = FormatUtils.getInitials(patientName);

    return AnimatedPress(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              AvatarWidget(initials: initials, colorIndex: colorIndex, size: 46, fontSize: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(specialty,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  if (queueNumber != null)
                    Text('Số $queueNumber',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  _badge(status),
                ],
              ),
              const SizedBox(width: 10),
              if (status == AppointmentStatus.done)
                IconButton(
                  icon: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary),
                  onPressed: () {
                    final dateStr = '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordDetailScreen(
                          appointmentId: appointmentId,
                          patientName: patientName,
                          date: dateStr,
                        ),
                      ),
                    );
                  },
                )
              else
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
            ],
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
