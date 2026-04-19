import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?>? get authStateChanges => null;

  // ==================== SỬA Ở ĐÂY ====================
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          String errorMsg = e.message ?? 'Xác thực thất bại';
          if (e.code == 'invalid-phone-number') errorMsg = 'Số điện thoại không hợp lệ';
          if (e.code == 'too-many-requests') errorMsg = 'Thử quá nhiều lần. Chờ một chút rồi thử lại!';
          print('❌ Verification Failed: ${e.code} - $errorMsg');
          onError(errorMsg);
        },

        codeSent: (String verificationId, int? resendToken) {
          print('✅ CODE SENT THÀNH CÔNG! VerificationId = $verificationId');  // Dòng debug quan trọng
          if (verificationId.isEmpty) {
            onError('VerificationId rỗng từ Firebase');
            return;
          }
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Timeout: $verificationId');
          onCodeSent(verificationId);
        },
      );
    } catch (e) {
      print('❌ Lỗi sendOtp: $e');
      onError('Lỗi hệ thống: $e');
    }
  }

  // ==================== HÀM XÁC NHẬN OTP (SỬA LẠI) ====================
  Future<UserCredential?> verifyOtp({
    required String verificationId,     // ← Nhận trực tiếp từ màn hình
    required String smsCode,
    required Function(String) onError,
  }) async {
    if (verificationId.isEmpty) {
      onError('Verification ID bị rỗng. Hãy gửi OTP lại.');
      return null;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      String msg = 'Mã OTP không đúng hoặc đã hết hạn';
      if (e.toString().contains('invalid-verification-code')) msg = 'OTP sai';
      if (e.toString().contains('session-expired')) msg = 'Phiên hết hạn, gửi lại OTP';
      print('❌ Verify OTP Error: $e');
      onError(msg);
      return null;
    }
  }
  // ==================== TẠO USER SAU KHI ĐĂNG NHẬP THÀNH CÔNG ====================
  Future<void> createUserAfterOtp({
    required String uid,
    required String phone,
    required String fullName,
    required String role,
  }) async {
    try {
      // Tạo thông tin user chung
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'phone': phone,
        'fullName': fullName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (role == 'doctor') {
        await _firestore.collection('doctors').doc(uid).set({
          'doctorId': uid,
          'fullName': fullName,
          'specialty': '',
          'clinicName': '',
          'workStartTime': '',
          'workEndTime': '',
          'address': '',
          'bio': '',
          'avatarUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else if (role == 'patient') {
        await _firestore.collection('patients').doc(uid).set({
          'patientId': uid,
          'fullName': fullName,
          'dateOfBirth': '',
          'gender': '',
          'bloodType': '',
          'height': 0,
          'weight': 0,
          'allergies': [],
          'chronicDiseases': [],
          'address': '',
          'emergencyContactName': '',
          'emergencyContactPhone': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Lỗi tạo user sau OTP: $e');
      rethrow;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}