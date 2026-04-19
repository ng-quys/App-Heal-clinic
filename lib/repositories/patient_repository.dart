import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _patients => _db.collection('patients');

  Future<PatientModel?> getPatientById(String patientId) async {
    final doc = await _patients.doc(patientId).get();
    if (!doc.exists) return null;
    return PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    final snap = await _patients
        .orderBy('fullName')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();
    return snap.docs
        .map((doc) =>
            PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<PatientModel>> getPatientsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => getPatientById(id));
    final results = await Future.wait(futures);
    return results.whereType<PatientModel>().toList();
  }
}
