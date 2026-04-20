import '../models/Doctor.dart';
import '../services/Doctor_Service.dart';

class DoctorController {
  final DoctorService _service = DoctorService();

  //ấy danh sách doctor
  Future<List<Doctor>> getDoctors() async {
    try {
      return await _service.getDoctors();
    } catch (e) {
      print("Error getDoctors: $e");
      return [];
    }
  }

  //Thêm doctor
  Future<bool> addDoctor(Doctor doctor) async {
    try {
      await _service.addDoctor(doctor);
      return true;
    } catch (e) {
      print("Error addDoctor: $e");
      return false;
    }
  }

  //Cập nhật doctor
  Future<bool> updateDoctor(Doctor doctor) async {
    try {
      await _service.updateDoctor(doctor);
      return true;
    } catch (e) {
      print("Error updateDoctor: $e");
      return false;
    }
  }

  //Xóa doctor
  Future<bool> deleteDoctor(String id) async {
    try {
      await _service.deleteDoctor(id);
      return true;
    } catch (e) {
      print("Error deleteDoctor: $e");
      return false;
    }
  }

  //Search theo tên
  Future<List<Doctor>> searchDoctor(String keyword) async {
    try {
      if (keyword.isEmpty) {
        return await getDoctors(); // nếu rỗng thì load lại
      }
      return await _service.searchDoctor(keyword);
    } catch (e) {
      print("Error searchDoctor: $e");
      return [];
    }
  }

  //Lọc theo chuyên khoa
  Future<List<Doctor>> filterBySpecialty(String specialty) async {
    try {
      return await _service.getBySpecialty(specialty);
    } catch (e) {
      print("Error filter: $e");
      return [];
    }
  }
}