import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import '../models/appointment_model.dart';
import '../constants/api_config.dart';

class AppointmentService {
  static const String baseUrl = ApiConfig.appointmentUrl;

  static HubConnection? _hubConnection;
  static StreamController<List<AppointmentModel>>? _queueController;
  static StreamController<List<AppointmentModel>>? _allAppointmentsController;

  void _setupSignalR(String doctorId) async {
    if (_hubConnection != null) return;

    final hubUrl = ApiConfig.queueHubUrl;

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();

    _hubConnection!.onclose(({Exception? error}) {
      debugPrint("SignalR connection closed: $error");
    });

    _hubConnection!.on("QueueUpdated", (arguments) async {
      debugPrint("SignalR: Queue updated event received!");

      if (_queueController != null && !_queueController!.isClosed) {
        final queue = await _fetchQueueFromApi(doctorId);
        _queueController!.add(queue);
      }

      if (_allAppointmentsController != null && !_allAppointmentsController!.isClosed) {
        final all = await getAppointmentsByDoctor(doctorId);
        _allAppointmentsController!.add(all);
      }
    });

    try {
      await _hubConnection!.start();
      debugPrint("SignalR: Connection started successfully!");
      await _hubConnection!.invoke("JoinDoctorRoom", args: [doctorId]);
      debugPrint("SignalR: Joined room for doctor $doctorId");
    } catch (e) {
      debugPrint("SignalR error starting connection: $e");
    }
  }

  Future<List<AppointmentModel>> _fetchQueueFromApi(String doctorId) async {
    final appointments = await getAppointmentsByDoctor(doctorId);
    return appointments.where((a) =>
      a.status == AppointmentStatus.confirmed ||
      a.status == AppointmentStatus.inProgress ||
      a.status == AppointmentStatus.pending
    ).toList();
  }

  Future<void> refreshQueue(String doctorId) async {
    if (_queueController != null && !_queueController!.isClosed) {
      final queue = await _fetchQueueFromApi(doctorId);
      _queueController!.add(queue);
    }
    if (_allAppointmentsController != null && !_allAppointmentsController!.isClosed) {
      final all = await getAppointmentsByDoctor(doctorId);
      _allAppointmentsController!.add(all);
    }
  }

  Future<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/doctor/$doctorId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => AppointmentModel.fromMap(item, item['appointmentId'].toString())).toList();
      } else {
        debugPrint('Failed to load appointments: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
  }

  Stream<List<AppointmentModel>> watchAllAppointments(String doctorId) {
    if (_allAppointmentsController == null || _allAppointmentsController!.isClosed) {
      _allAppointmentsController = StreamController<List<AppointmentModel>>.broadcast(
        onListen: () {
          _setupSignalR(doctorId);
          getAppointmentsByDoctor(doctorId).then((data) {
            if (_allAppointmentsController != null && !_allAppointmentsController!.isClosed) {
              _allAppointmentsController!.add(data);
            }
          });
        }
      );
    }
    return _allAppointmentsController!.stream;
  }

  Stream<List<AppointmentModel>> watchTodayAppointments(String doctorId) async* {
    final appointments = await getAppointmentsByDoctor(doctorId);
    yield appointments.toList();
  }

  Stream<List<AppointmentModel>> watchAppointmentsByDate(String doctorId, DateTime date) async* {
    final appointments = await getAppointmentsByDoctor(doctorId);
    yield appointments.where((a) =>
      a.scheduledAt.year == date.year &&
      a.scheduledAt.month == date.month &&
      a.scheduledAt.day == date.day
    ).toList();
  }

  Stream<List<AppointmentModel>> watchQueue(String doctorId) {
    if (_queueController == null || _queueController!.isClosed) {
      _queueController = StreamController<List<AppointmentModel>>.broadcast(
        onListen: () {
          _setupSignalR(doctorId);
          _fetchQueueFromApi(doctorId).then((data) {
            if (_queueController != null && !_queueController!.isClosed) {
              _queueController!.add(data);
            }
          });
        }
      );
    }
    return _queueController!.stream;
  }

  Future<List<AppointmentModel>> getPatientHistory(String doctorId, String patientId) async {
    final appointments = await getAppointmentsByDoctor(doctorId);
    return appointments.where((a) => a.patientId == patientId).toList();
  }

  Future<List<AppointmentModel>> getUpcomingAppointments(String doctorId) async {
    final appointments = await getAppointmentsByDoctor(doctorId);
    final now = DateTime.now();
    // Start from tomorrow
    final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    final endOfNext7Days = startOfTomorrow.add(const Duration(days: 7));
    
    final upcoming = appointments.where((a) =>
      a.scheduledAt.isAfter(startOfTomorrow) &&
      a.scheduledAt.isBefore(endOfNext7Days) &&
      a.status != AppointmentStatus.cancelled
    ).toList();
    
    upcoming.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return upcoming;
  }

  Future<bool> updateStatus(String appointmentId, String status) async {
    try {
      final url = Uri.parse('$baseUrl/$appointmentId/status').replace(queryParameters: {'newStatus': status});
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return true;
      }
      debugPrint('Failed to update status: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  Future<void> markAsDone(String appointmentId, {String? doctorId}) async {
    await updateStatus(appointmentId, 'Đã khám');
    if (doctorId != null) await refreshQueue(doctorId);
  }

  Future<void> confirmAppointment(String appointmentId, {String? doctorId}) async {
    await updateStatus(appointmentId, 'Đã xác nhận');
    if (doctorId != null) await refreshQueue(doctorId);
  }

  Future<void> markInProgress(String appointmentId, {String? doctorId}) async {
    await updateStatus(appointmentId, 'Đang khám');
    if (doctorId != null) await refreshQueue(doctorId);
  }

  Future<void> cancelAppointment(String appointmentId, {String? doctorId}) async {
    await updateStatus(appointmentId, 'Đã hủy');
    if (doctorId != null) await refreshQueue(doctorId);
  }

  Future<void> saveNotes(String appointmentId, String notes) async {
    // Gọi API update note
  }

  Future<List<DateTime>> getMonthAppointmentDates(String doctorId, int year, int month) async {
    final appointments = await getAppointmentsByDoctor(doctorId);
    return appointments
        .where((a) => a.scheduledAt.year == year && a.scheduledAt.month == month)
        .map((a) => DateTime(a.scheduledAt.year, a.scheduledAt.month, a.scheduledAt.day))
        .toSet()
        .toList();
  }

  Map<String, int> getTodaySummary(List<AppointmentModel> appointments) {
    return {
      'total': appointments.length,
      'done': appointments.where((a) => a.status == AppointmentStatus.done).length,
      'waiting': appointments
          .where((a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.pending)
          .length,
      'inProgress':
          appointments.where((a) => a.status == AppointmentStatus.inProgress).length,
    };
  }
}


