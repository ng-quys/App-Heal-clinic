import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../theme.dart';
import 'widgets/queue_components.dart';
import '../../../widgets/common/common_widgets.dart';

class QueueScreen extends StatelessWidget {
  final String doctorId;
  const QueueScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<AppointmentModel>>(
          stream: appointmentService.watchQueue(doctorId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snap.hasError) {
              return const Center(
                child: Text('Đã xảy ra lỗi khi tải dữ liệu', style: TextStyle(color: AppColors.danger)),
              );
            }
            final queue = snap.data ?? [];
            final current =
                queue.where((a) => a.status == AppointmentStatus.inProgress).firstOrNull;
            final waiting =
                queue.where((a) => a.status == AppointmentStatus.confirmed).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, waiting.length),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (current != null) ...[
                        CurrentPatientCard(
                          appt: current,
                          appointmentService: appointmentService,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        EmptyCurrentCard(
                          hasWaiting: waiting.isNotEmpty,
                          nextAppt: waiting.firstOrNull,
                          appointmentService: appointmentService,
                          doctorId: doctorId,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (waiting.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(4, 8, 4, 16),
                          child: Text(
                            'Đang chờ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        ...waiting.map((appt) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              useShadow: true,
                              child: QueueWaitingRow(
                                appt: appt,
                                onSkip: () => appointmentService
                                    .cancelAppointment(appt.appointmentId),
                              ),
                            ),
                          );
                        }),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int waitingCount) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(8, 12, 18, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hàng chờ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('$waitingCount bệnh nhân đang chờ',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

