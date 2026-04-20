class Reminders{
  DateTime createAt;
  String doSage;
  DateTime startDate;
  DateTime endDate;
  String frequency;
  bool isActive;
  String medicineName;
  String note;
  String patientId;
  String remindId;
  DateTime time;

  Reminders({
    required this.createAt,
    required this.doSage,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.isActive,
    required this.medicineName,
    required this.note,
    required this.patientId,
    required this.remindId,
    required this.time,
});

  Map<String, dynamic> toMap() {
    return {
      'createAt': createAt,
      'doSage': doSage,
      'startDate': startDate,
      'endDate': endDate,
      'frequency': frequency,
      'isActive': isActive,
      'medicineName': medicineName,
      'note': note,
      'patientId': patientId,
      'remindId': remindId,
      'time': time,
    };
  }

  factory Reminders.fromMap(Map<String, dynamic> map) {
    return Reminders(
      createAt: map['createAt'] as DateTime,
      doSage: map['doSage'],
      startDate: map['startDate'] as DateTime,
        endDate: map['endDate'] as DateTime,
        frequency: map['frequency'],
        isActive: map['isActive'],
        medicineName: map['medicineName'],
        note: map['note'],
        patientId: map['patientId'],
        remindId: map['remindId'],
        time: map['time'] as DateTime,);
  }


}