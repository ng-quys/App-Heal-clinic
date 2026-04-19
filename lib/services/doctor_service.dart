import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';

class DoctorService {
  final DoctorRepository _doctorRepository;

  DoctorService({DoctorRepository? doctorRepository})
      : _doctorRepository = doctorRepository ?? DoctorRepository();

  Future<DoctorModel?> getDoctorProfile(String uid) async {
    return await _doctorRepository.getDoctorById(uid);
  }

  Stream<DoctorModel?> watchDoctorProfile(String uid) {
    return _doctorRepository.watchDoctor(uid);
  }

  Future<void> toggleAvailability(String uid, bool isAvailable) async {
    await _doctorRepository.updateAvailability(uid, isAvailable);
  }

  Future<void> updateProfile(String uid, {
    String? fullName,
    String? specialty,
    String? clinicName,
    String? workStartTime,
    String? workEndTime,
    String? address,
    String? bio,
    String? avatarUrl,
  }) async {
    final fields = <String, dynamic>{};
    if (fullName != null) fields['fullName'] = fullName;
    if (specialty != null) fields['specialty'] = specialty;
    if (clinicName != null) fields['clinicName'] = clinicName;
    if (workStartTime != null) fields['workStartTime'] = workStartTime;
    if (workEndTime != null) fields['workEndTime'] = workEndTime;
    if (address != null) fields['address'] = address;
    if (bio != null) fields['bio'] = bio;
    if (avatarUrl != null) fields['avatarUrl'] = avatarUrl;

    if (fields.isEmpty) return;
    await _doctorRepository.updateProfile(uid, fields);
  }
}
