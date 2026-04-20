import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Doctor.dart';

class DoctorService {
  final CollectionReference doctors =
  FirebaseFirestore.instance.collection('doctors');

  //Lấy tất cả doctor
  Future<List<Doctor>> getDoctors() async {
    final snapshot = await doctors.get();

    return snapshot.docs.map((doc) {
      return Doctor.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  //Thêm doctor
  Future<void> addDoctor(Doctor doctor) async {
    await doctors.add(doctor.toMap());
  }

  //Cập nhật doctor
  Future<void> updateDoctor(Doctor doctor) async {
    await doctors.doc(doctor.doctorId).update(doctor.toMap());
  }

  //Xóa doctor
  Future<void> deleteDoctor(String id) async {
    await doctors.doc(id).delete();
  }

  //Search theo tên (prefix search)
  Future<List<Doctor>> searchDoctor(String keyword) async {
    final snapshot = await doctors
        .orderBy('fullName')
        .startAt([keyword])
        .endAt([keyword + '\uf8ff'])
        .get();

    return snapshot.docs.map((doc) {
      return Doctor.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  //Lọc theo chuyên khoa
  Future<List<Doctor>> getBySpecialty(String specialty) async {
    final snapshot = await doctors
        .where('specialty', isEqualTo: specialty)
        .get();

    return snapshot.docs.map((doc) {
      return Doctor.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }
}