import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../theme.dart';
import '../../../constants/api_config.dart';

class MedicalRecordScreen extends StatefulWidget {
  final String appointmentId;
  final String patientId;

  const MedicalRecordScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _diagnosis = '';
  String _symptoms = '';
  String _treatment = '';
  bool _isCover = false;
  double _percentCover = 0;
  String _prescriptionNote = '';
  final List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;

  void _addMedication() {
    setState(() {
      _medications.add({
        'medicationId': 'MED01',
        'name': '',
        'duration': 5,
        'quantity': 1,
        'note': '',
        'price': 25000,
      });
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _submitCheckout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final payload = {
      'appointmentId': int.tryParse(widget.appointmentId) ?? 0,
      'patientId': widget.patientId,
      'diagnosis': _diagnosis,
      'symptoms': _symptoms,
      'treatment': _treatment,
      'isCover': _isCover,
      'percentCover': _percentCover,
      'prescriptionNote': _prescriptionNote,
      'medications': _medications.map((m) => {
        'medicationId': m['medicationId'],
        'duration': m['duration'],
        'quantity': m['quantity'],
        'note': '${m['name']} - ${m['note']}',
        'price': m['price'],
      }).toList(),
    };

    try {
      final url = Uri.parse('${ApiConfig.medicalRecordUrl}/checkout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tạo hồ sơ bệnh án thành công!')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${response.body}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi kết nối: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm Hồ Sơ Bệnh Án',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Chẩn đoán & Triệu chứng'),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Chẩn đoán'),
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                      onSaved: (v) => _diagnosis = v!,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Triệu chứng'),
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                      onSaved: (v) => _symptoms = v!,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Hướng điều trị'),
                      onSaved: (v) => _treatment = v ?? '',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Đơn thuốc'),
                    ..._medications.asMap().entries.map((e) {
                      final i = e.key;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Thuốc ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _removeMedication(i),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      decoration: const InputDecoration(labelText: 'Tên thuốc', isDense: true),
                                      onChanged: (v) => _medications[i]['name'] = v,
                                      initialValue: _medications[i]['name'],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      decoration: const InputDecoration(labelText: 'Số lượng', isDense: true),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => _medications[i]['quantity'] = int.tryParse(v) ?? 1,
                                      initialValue: _medications[i]['quantity'].toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addMedication,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm loại thuốc'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Ghi chú chung (vd: uống sau khi ăn, trước khi ăn...)'),
                      onSaved: (v) => _prescriptionNote = v ?? '',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Bảo hiểm y tế (BHYT)'),
                    SwitchListTile(
                      title: const Text('Áp dụng BHYT'),
                      value: _isCover,
                      onChanged: (v) => setState(() => _isCover = v),
                    ),
                    if (_isCover)
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Phần trăm hỗ trợ (%)'),
                        keyboardType: TextInputType.number,
                        initialValue: '80',
                        onSaved: (v) => _percentCover = double.tryParse(v ?? '0') ?? 0,
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submitCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Hoàn tất & Lưu bệnh án', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
