import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _doctors => _db.collection('doctors');

  Future<DoctorModel?> getDoctorById(String uid) async {
    final doc = await _doctors.doc(uid).get();
    if (!doc.exists) return null;
    return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Stream<DoctorModel?> watchDoctor(String uid) {
    return _doctors.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Future<void> updateAvailability(String uid, bool isAvailable) async {
    await _doctors.doc(uid).update({
      'isAvailable': isAvailable,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await _doctors.doc(uid).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> createDoctorProfile(DoctorModel doctor) async {
    await _doctors.doc(doctor.doctorId).set(doctor.toMap());
  }
}
