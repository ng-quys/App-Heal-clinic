import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';

class QueueScreen extends StatelessWidget {
  final String doctorId;
  const QueueScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();

    return SafeArea(
      child: StreamBuilder<List<AppointmentModel>>(
        stream: appointmentService.watchQueue(doctorId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          final queue = snap.data ?? [];
          final current =
              queue.where((a) => a.status == AppointmentStatus.inProgress).firstOrNull;
          final waiting =
              queue.where((a) => a.status == AppointmentStatus.confirmed).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(waiting.length)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (current != null) ...[
                      _CurrentPatientCard(
                        appt: current,
                        appointmentService: appointmentService,
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      _EmptyCurrentCard(
                        hasWaiting: waiting.isNotEmpty,
                        nextAppt: waiting.firstOrNull,
                        appointmentService: appointmentService,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (waiting.isNotEmpty) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Text(
                                'Đang chờ (${waiting.length})',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                            const Divider(height: 0),
                            ...waiting.asMap().entries.map((entry) {
                              final i = entry.key;
                              final appt = entry.value;
                              return _WaitingRow(
                                appt: appt,
                                isLast: i == waiting.length - 1,
                                onSkip: () => appointmentService
                                    .cancelAppointment(appt.appointmentId),
                              );
                            }),
                          ],
                        ),
                      ),
                    ] else if (current == null) ...[
                      const EmptyStateWidget(
                        message: 'Hàng chờ trống',
                        icon: Icons.people_outline,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int waitingCount) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hàng chờ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('$waitingCount bệnh nhân đang chờ',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CurrentPatientCard extends StatelessWidget {
  final AppointmentModel appt;
  final AppointmentService appointmentService;

  const _CurrentPatientCard({required this.appt, required this.appointmentService});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(appt.patientName);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white.withOpacity(0.2),
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
                    '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      appointmentService.cancelAppointment(appt.appointmentId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: const Text('Bỏ qua', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () =>
                      appointmentService.markAsDone(appt.appointmentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: const Text('Hoàn thành',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ),
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
}

class _EmptyCurrentCard extends StatelessWidget {
  final bool hasWaiting;
  final AppointmentModel? nextAppt;
  final AppointmentService appointmentService;

  const _EmptyCurrentCard({
    required this.hasWaiting,
    required this.nextAppt,
    required this.appointmentService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasWaiting
                  ? 'Nhấn để gọi bệnh nhân tiếp theo vào'
                  : 'Không có bệnh nhân đang chờ',
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
          if (hasWaiting && nextAppt != null)
            ElevatedButton(
              onPressed: () =>
                  appointmentService.markInProgress(nextAppt!.appointmentId),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Gọi vào'),
            ),
        ],
      ),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  final AppointmentModel appt;
  final bool isLast;
  final VoidCallback onSkip;

  const _WaitingRow({
    required this.appt,
    required this.isLast,
    required this.onSkip,
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
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${appt.queueNumber ?? '-'}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary)),
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
          Text(
            '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
