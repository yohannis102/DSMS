class ScheduleModel {
  final String id;
  final String scheduleCode;
  final String date;
  final String? rawDate;
  final String time;
  final String instructorId;
  final String instructor;
  final String? instructorEmail;
  final String? instructorUsername;
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
    this.rawDate,
    this.time = '09:00 AM - 11:00 AM',
    this.instructorId = '',
    required this.instructor,
    this.instructorEmail,
    this.instructorUsername,
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

    final rawDateStr = json['date']?.toString() ?? '';
    String parsedDate = rawDateStr;
    String parsedTime =
        json['time']?.toString() ?? json['timeSlot']?.toString() ?? '';

    if (rawDateStr.isNotEmpty) {
      final dt = DateTime.tryParse(rawDateStr);
      if (dt != null) {
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        parsedDate = '$y-$m-$d';

        if (parsedTime.isEmpty && rawDateStr.contains('T')) {
          final hour = dt.hour;
          final minute = dt.minute;
          final period = hour >= 12 ? 'PM' : 'AM';
          final h12 = hour % 12 == 0 ? 12 : hour % 12;
          final endHour = (hour + 2) % 24;
          final endPeriod = endHour >= 12 ? 'PM' : 'AM';
          final endH12 = endHour % 12 == 0 ? 12 : endHour % 12;
          final startStr =
              '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
          final endStr =
              '${endH12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $endPeriod';
          parsedTime = '$startStr - $endStr';
        }
      }
    }
    if (parsedTime.isEmpty) {
      parsedTime = '09:00 AM - 11:00 AM';
    }

    String parsedInstructorId = json['instructorId']?.toString() ?? '';
    String parsedInstructorName = json['instructorName']?.toString() ?? '';
    String? parsedInstructorEmail;
    String? parsedInstructorUsername;

    final rawInstructor = json['instructor'];
    if (rawInstructor is Map<String, dynamic> || rawInstructor is Map) {
      final insMap = Map<String, dynamic>.from(rawInstructor as Map);
      parsedInstructorId =
          insMap['_id']?.toString() ??
          insMap['id']?.toString() ??
          parsedInstructorId;
      parsedInstructorEmail = insMap['email']?.toString();
      parsedInstructorUsername = insMap['username']?.toString();

      final first = insMap['firstName']?.toString() ?? '';
      final middle = insMap['middleName']?.toString() ?? '';
      final last = insMap['lastName']?.toString() ?? '';
      final parts = [first, middle, last]
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        parsedInstructorName = parts.join(' ');
      } else if (insMap['name'] != null &&
          insMap['name'].toString().isNotEmpty) {
        parsedInstructorName = insMap['name'].toString();
      } else if (parsedInstructorUsername != null &&
          parsedInstructorUsername.isNotEmpty) {
        parsedInstructorName = parsedInstructorUsername;
      }
    } else if (rawInstructor != null) {
      final str = rawInstructor.toString().trim();
      final isMongoId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(str);
      if (isMongoId) {
        parsedInstructorId = str;
        if (parsedInstructorName.isEmpty) {
          parsedInstructorName = 'Instructor ($str)';
        }
      } else if (parsedInstructorName.isEmpty) {
        parsedInstructorName = str;
      }
    }

    if (parsedInstructorName.isEmpty) {
      parsedInstructorName =
          (parsedInstructorId.isNotEmpty
              ? 'Instructor ($parsedInstructorId)'
              : 'Unassigned');
    }

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
      date: parsedDate,
      rawDate: rawDateStr.isNotEmpty ? rawDateStr : null,
      time: parsedTime,
      instructorId: parsedInstructorId,
      instructor: parsedInstructorName,
      instructorEmail: parsedInstructorEmail,
      instructorUsername: parsedInstructorUsername,
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
    'instructor': instructorId.isNotEmpty ? instructorId : instructor,
    'instructorId': instructorId,
    'instructorName': instructor,
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
    String? rawDate,
    String? time,
    String? instructorId,
    String? instructor,
    String? instructorEmail,
    String? instructorUsername,
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
      rawDate: rawDate ?? this.rawDate,
      time: time ?? this.time,
      instructorId: instructorId ?? this.instructorId,
      instructor: instructor ?? this.instructor,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      instructorUsername: instructorUsername ?? this.instructorUsername,
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
