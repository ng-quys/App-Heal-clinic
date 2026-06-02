import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/medication_model.dart';
import '../../../../models/service_model.dart';
import '../../../../services/medical_record_service.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/medication_service.dart';
import '../../../../services/service_api_service.dart';
import '../../../../theme.dart';
import '../../../../widgets/common/common_widgets.dart';

class ExaminationScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const ExaminationScreen({super.key, required this.appointment});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _diagnosisCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _percentCoverCtrl = TextEditingController(text: '0');
  final _prescriptionNoteCtrl = TextEditingController();

  bool _isCover = false;
  bool _isLoading = false;

  List<MedicationModel> _allMedications = [];
  List<ServiceModel> _allServices = [];

  final List<Map<String, dynamic>> _selectedMedications = [];
  final List<Map<String, dynamic>> _selectedServices = [];

  final _medicationService = MedicationService();
  final _serviceApiService = ServiceApiService();
  final _medicalRecordService = MedicalRecordService();
  final _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final meds = await _medicationService.getMedications();
      final svcs = await _serviceApiService.getServices();
      setState(() {
        _allMedications = meds;
        _allServices = svcs;
      });
    } catch (e) {
      debugPrint('Error loading master data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final checkoutData = {
      "appointmentId": int.parse(widget.appointment.appointmentId),
      "patientId": widget.appointment.patientId,
      "diagnosis": _diagnosisCtrl.text,
      "symptoms": _symptomsCtrl.text,
      "treatment": _treatmentCtrl.text,
      "isCover": _isCover,
      "percentCover": int.tryParse(_percentCoverCtrl.text) ?? 0,
      "prescriptionNote": _prescriptionNoteCtrl.text,
      "medications": _selectedMedications.map((m) => {
        "medicationId": m['medicationId'],
        "duration": m['duration'],
        "quantity": m['quantity'],
        "note": m['note'],
        "price": m['price']
      }).toList(),
      "services": _selectedServices.map((s) => {
        "serviceId": s['serviceId'],
        "quantity": s['quantity']
      }).toList()
    };

    final success = await _medicalRecordService.checkout(checkoutData);
    setState(() => _isLoading = false);

    if (success && mounted) {
      await _appointmentService.refreshQueue(widget.appointment.doctorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hoàn thành khám và lưu hồ sơ')));
        Navigator.pop(context); // Go back to Queue Screen
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu hồ sơ thất bại')));
    }
  }

  void _showAddMedicationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddMedicationForm(
        allMedications: _allMedications,
        onAdd: (medItem) {
          setState(() => _selectedMedications.add(medItem));
        },
      )
    );
  }

  void _showAddServiceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddServiceForm(
        allServices: _allServices,
        onAdd: (svcItem) {
          setState(() => _selectedServices.add(svcItem));
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ Khám bệnh', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
                    ),
                    child: PrimaryButton(
                      text: 'HOÀN THÀNH KHÁM',
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPatientInfo(),
                const SizedBox(height: 16),
                _buildSectionTitle('1. Bệnh án'),
                _buildTextField('Chẩn đoán', _diagnosisCtrl),
                const SizedBox(height: 12),
                _buildTextField('Triệu chứng', _symptomsCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField('Hướng điều trị', _treatmentCtrl, maxLines: 2),
                
                const SizedBox(height: 20),
                _buildSectionTitle('2. Bảo hiểm y tế'),
                SwitchListTile(
                  title: const Text('Áp dụng BHYT', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: _isCover,
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isCover = val),
                ),
                if (_isCover)
                  _buildTextField('Phần trăm miễn giảm (%)', _percentCoverCtrl, isNumber: true),

                const SizedBox(height: 20),
                _buildSectionTitle('3. Kê đơn thuốc', trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _showAddMedicationModal,
                )),
                if (_selectedMedications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Chưa kê loại thuốc nào', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  )
                else
                  ..._selectedMedications.map((m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${m['medicineName']} (SL: ${m['quantity']})', style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Cách dùng: ${m['note']} - Uống ${m['duration']} ngày'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.danger),
                      onPressed: () => setState(() => _selectedMedications.remove(m)),
                    ),
                  )),
                const SizedBox(height: 8),
                _buildTextField('Ghi chú đơn thuốc', _prescriptionNoteCtrl, maxLines: 2),

                const SizedBox(height: 20),
                _buildSectionTitle('4. Chỉ định Dịch vụ', trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _showAddServiceModal,
                )),
                if (_selectedServices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Chưa chỉ định dịch vụ nào', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  )
                else
                  ..._selectedServices.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s['serviceName'], style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('SL: ${s['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.danger),
                      onPressed: () => setState(() => _selectedServices.remove(s)),
                    ),
                  )),
              ],
            ),
          ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.appointment.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Lý do khám: ${widget.appointment.reason}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        if (trailing != null) trailing
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        ),
      ),
    );
  }
}

class _AddMedicationForm extends StatefulWidget {
  final List<MedicationModel> allMedications;
  final Function(Map<String, dynamic>) onAdd;

  const _AddMedicationForm({required this.allMedications, required this.onAdd});

  @override
  State<_AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<_AddMedicationForm> {
  MedicationModel? _selectedMed;
  final _quantityCtrl = TextEditingController(text: '1');
  final _durationCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thêm Thuốc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<MedicationModel>(
            decoration: const InputDecoration(labelText: 'Chọn thuốc', border: OutlineInputBorder()),
            items: widget.allMedications.map((m) => DropdownMenuItem(value: m, child: Text(m.medicineName))).toList(),
            onChanged: (val) => setState(() => _selectedMed = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số ngày uống', border: OutlineInputBorder()))),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Cách dùng (Ghi chú)', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'THÊM',
            onPressed: () {
              if (_selectedMed != null) {
                widget.onAdd({
                  "medicationId": _selectedMed!.medicationId,
                  "medicineName": _selectedMed!.medicineName,
                  "duration": int.tryParse(_durationCtrl.text) ?? 1,
                  "quantity": int.tryParse(_quantityCtrl.text) ?? 1,
                  "note": _noteCtrl.text,
                  "price": _selectedMed!.price
                });
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AddServiceForm extends StatefulWidget {
  final List<ServiceModel> allServices;
  final Function(Map<String, dynamic>) onAdd;

  const _AddServiceForm({required this.allServices, required this.onAdd});

  @override
  State<_AddServiceForm> createState() => _AddServiceFormState();
}

class _AddServiceFormState extends State<_AddServiceForm> {
  ServiceModel? _selectedSvc;
  final _quantityCtrl = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chỉ định Dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<ServiceModel>(
            decoration: const InputDecoration(labelText: 'Chọn dịch vụ', border: OutlineInputBorder()),
            items: widget.allServices.map((s) => DropdownMenuItem(value: s, child: Text(s.serviceName))).toList(),
            onChanged: (val) => setState(() => _selectedSvc = val),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'THÊM',
            onPressed: () {
              if (_selectedSvc != null) {
                widget.onAdd({
                  "serviceId": _selectedSvc!.serviceId,
                  "serviceName": _selectedSvc!.serviceName,
                  "quantity": int.tryParse(_quantityCtrl.text) ?? 1,
                  "price": _selectedSvc!.price
                });
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
