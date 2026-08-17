class ScheduleModel {
  final String id;
  final String scheduleCode;
  final String date;
  final String time;
  final String instructor;
  final int slotsAvailable;
  final int totalSlots;
  final double amount;
  final String remarks;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const ScheduleModel({
    required this.id,
    required this.scheduleCode,
    required this.date,
    this.time = '09:00 AM - 11:00 AM',
    required this.instructor,
    this.slotsAvailable = 1,
    this.totalSlots = 1,
    this.amount = 0.0,
    this.remarks = '',
    this.status = 'Available',
    this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable =>
      slotsAvailable > 0 &&
      status.toLowerCase() != 'cancelled' &&
      status.toLowerCase() != 'completed';
  bool get isFull => slotsAvailable <= 0;

  String get formattedAmount {
    if (amount <= 0) return 'Free';
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAllMapped(
      reg,
      (Match m) => '${m[1]},',
    );
    return 'ETB $formattedInt.$decimalPart';
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final code =
        json['scheduleCode']?.toString() ??
        json['code']?.toString() ??
        (rawId.startsWith('SCH-')
            ? rawId
            : (rawId.isNotEmpty
                  ? 'SCH-${rawId.substring(rawId.length > 6 ? rawId.length - 6 : 0)}'
                  : 'SCH-001'));

    final parsedSlots =
        int.tryParse(
          json['slotsAvailable']?.toString() ??
              json['slots']?.toString() ??
              json['noOfSlots']?.toString() ??
              '1',
        ) ??
        1;
    final parsedTotalSlots =
        int.tryParse(json['totalSlots']?.toString() ?? '') ?? parsedSlots;

    final parsedAmount =
        double.tryParse(
          json['amount']?.toString() ??
              json['price']?.toString() ??
              json['fee']?.toString() ??
              '0',
        ) ??
        0.0;

    return ScheduleModel(
      id: rawId.isNotEmpty ? rawId : code,
      scheduleCode: code,
      date: json['date']?.toString() ?? '',
      time:
          json['time']?.toString() ??
          json['timeSlot']?.toString() ??
          '09:00 AM - 11:00 AM',
      instructor:
          json['instructor']?.toString() ??
          json['instructorName']?.toString() ??
          'Unassigned',
      slotsAvailable: parsedSlots,
      totalSlots: parsedTotalSlots,
      amount: parsedAmount,
      remarks:
          json['remarks']?.toString() ??
          json['notes']?.toString() ??
          json['title']?.toString() ??
          '',
      status:
          json['status']?.toString() ??
          (parsedSlots > 0 ? 'Available' : 'Full'),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'scheduleCode': scheduleCode,
    'date': date,
    'time': time,
    'instructor': instructor,
    'slotsAvailable': slotsAvailable,
    'totalSlots': totalSlots,
    'amount': amount,
    'remarks': remarks,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  ScheduleModel copyWith({
    String? id,
    String? scheduleCode,
    String? date,
    String? time,
    String? instructor,
    int? slotsAvailable,
    int? totalSlots,
    double? amount,
    String? remarks,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      scheduleCode: scheduleCode ?? this.scheduleCode,
      date: date ?? this.date,
      time: time ?? this.time,
      instructor: instructor ?? this.instructor,
      slotsAvailable: slotsAvailable ?? this.slotsAvailable,
      totalSlots: totalSlots ?? this.totalSlots,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
