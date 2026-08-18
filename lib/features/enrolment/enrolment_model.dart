class EnrolmentScheduleInfo {
  final String id;
  final String scheduleCode;
  final String date;
  final int slotsAvailable;
  final double amount;

  const EnrolmentScheduleInfo({
    required this.id,
    this.scheduleCode = '',
    this.date = '',
    this.slotsAvailable = 0,
    this.amount = 0.0,
  });

  String get formattedDate {
    if (date.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(date);
    if (dt != null) {
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return date;
  }

  String get formattedTime {
    if (date.contains('T')) {
      final dt = DateTime.tryParse(date);
      if (dt != null) {
        final hour = dt.hour;
        final minute = dt.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final h12 = hour % 12 == 0 ? 12 : hour % 12;
        return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    }
    return '09:00 AM';
  }

  factory EnrolmentScheduleInfo.fromJson(dynamic json) {
    if (json == null) return const EnrolmentScheduleInfo(id: '');
    if (json is String) return EnrolmentScheduleInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return EnrolmentScheduleInfo(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        scheduleCode: map['scheduleCode']?.toString() ?? map['code']?.toString() ?? '',
        date: map['date']?.toString() ?? '',
        slotsAvailable: int.tryParse(map['slotsAvailable']?.toString() ?? map['slots']?.toString() ?? '0') ?? 0,
        amount: double.tryParse(map['amount']?.toString() ?? map['price']?.toString() ?? '0') ?? 0.0,
      );
    }
    return const EnrolmentScheduleInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'scheduleCode': scheduleCode,
        'date': date,
        'slotsAvailable': slotsAvailable,
        'amount': amount,
      };
}

class EnrolmentStudentInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phone;

  const EnrolmentStudentInfo({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.username = '',
    this.phone = '',
  });

  String get fullName {
    final parts = [firstName, lastName].where((s) => s.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (username.isNotEmpty) return username;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Student ($id)';
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (fullName.isNotEmpty) {
      return fullName[0].toUpperCase();
    }
    return 'S';
  }

  factory EnrolmentStudentInfo.fromJson(dynamic json) {
    if (json == null) return const EnrolmentStudentInfo(id: '');
    if (json is String) return EnrolmentStudentInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return EnrolmentStudentInfo(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        firstName: map['firstName']?.toString() ?? '',
        lastName: map['lastName']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        username: map['username']?.toString() ?? '',
        phone: map['contact']?.toString() ?? map['phone']?.toString() ?? '',
      );
    }
    return const EnrolmentStudentInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'phone': phone,
      };
}

class EnrolmentInstructorInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;

  const EnrolmentInstructorInfo({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.username = '',
  });

  String get fullName {
    final parts = [firstName, lastName].where((s) => s.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (username.isNotEmpty) return username;
    if (email.isNotEmpty) return email.split('@').first;
    if (id.isNotEmpty) return 'Instructor ($id)';
    return 'Unassigned';
  }

  factory EnrolmentInstructorInfo.fromJson(dynamic json) {
    if (json == null) return const EnrolmentInstructorInfo(id: '');
    if (json is String) return EnrolmentInstructorInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return EnrolmentInstructorInfo(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        firstName: map['firstName']?.toString() ?? '',
        lastName: map['lastName']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        username: map['username']?.toString() ?? '',
      );
    }
    return const EnrolmentInstructorInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
      };
}

class EnrolmentPackageInfo {
  final String id;
  final String name;
  final double price;
  final String description;

  const EnrolmentPackageInfo({
    required this.id,
    this.name = '',
    this.price = 0.0,
    this.description = '',
  });

  factory EnrolmentPackageInfo.fromJson(dynamic json) {
    if (json == null) return const EnrolmentPackageInfo(id: '');
    if (json is String) return EnrolmentPackageInfo(id: json, name: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return EnrolmentPackageInfo(
        id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? map['packageName']?.toString() ?? map['title']?.toString() ?? '',
        price: double.tryParse(map['price']?.toString() ?? map['amount']?.toString() ?? '0') ?? 0.0,
        description: map['description']?.toString() ?? '',
      );
    }
    return const EnrolmentPackageInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'price': price,
        'description': description,
      };
}

class EnrolmentModel {
  final String id;
  final EnrolmentScheduleInfo? schedule;
  final EnrolmentStudentInfo? student;
  final EnrolmentInstructorInfo? instructor;
  final EnrolmentPackageInfo? package;
  final String remarks;
  final String status;
  final String paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  // Legacy / Direct access fields
  final String? rawStudentName;
  final String? rawPackageName;
  final String? rawEnrolmentDate;
  final String? rawScheduleCode;

  const EnrolmentModel({
    required this.id,
    this.schedule,
    this.student,
    this.instructor,
    this.package,
    this.remarks = 'Enrolled by admin',
    this.status = 'Active',
    this.paymentStatus = 'Paid',
    this.createdAt,
    this.updatedAt,
    this.rawStudentName,
    this.rawPackageName,
    this.rawEnrolmentDate,
    this.rawScheduleCode,
  });

  // Backward-compatible & convenience getters
  String get enrolmentId => id;
  
  String get studentName {
    if (student != null && student!.fullName.isNotEmpty) return student!.fullName;
    if (rawStudentName != null && rawStudentName!.isNotEmpty) return rawStudentName!;
    return 'Unknown Student';
  }

  String get packageName {
    if (package != null && package!.name.isNotEmpty) return package!.name;
    if (rawPackageName != null && rawPackageName!.isNotEmpty) return rawPackageName!;
    return 'Standard Driving Course';
  }

  String get instructorName {
    if (instructor != null && instructor!.fullName.isNotEmpty) return instructor!.fullName;
    return 'Unassigned';
  }

  String get scheduleCode {
    if (schedule != null && schedule!.scheduleCode.isNotEmpty) return schedule!.scheduleCode;
    if (rawScheduleCode != null && rawScheduleCode!.isNotEmpty) return rawScheduleCode!;
    return 'SCH-GENERAL';
  }

  double get amount {
    if (package != null && package!.price > 0) return package!.price;
    if (schedule != null && schedule!.amount > 0) return schedule!.amount;
    return 0.0;
  }

  String get formattedAmount {
    final amt = amount;
    if (amt <= 0) return 'Free';
    final hasDecimals = amt % 1 != 0;
    final formattedNum = hasDecimals ? amt.toStringAsFixed(2) : amt.toStringAsFixed(0);
    final parts = formattedNum.split('.');
    final integerPart = parts[0];
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    if (parts.length > 1) {
      return 'ETB $formattedInt.${parts[1]}';
    }
    return 'ETB $formattedInt';
  }

  String get enrolmentDate {
    if (createdAt != null && createdAt!.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt!);
      if (dt != null) {
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        return '$y-$m-$d';
      }
    }
    if (schedule != null && schedule!.formattedDate.isNotEmpty) {
      return schedule!.formattedDate;
    }
    if (rawEnrolmentDate != null && rawEnrolmentDate!.isNotEmpty) {
      return rawEnrolmentDate!;
    }
    return 'N/A';
  }

  factory EnrolmentModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? json['enrolmentId']?.toString() ?? '';

    // Schedule Parsing
    EnrolmentScheduleInfo? parsedSchedule;
    if (json['schedule'] != null) {
      parsedSchedule = EnrolmentScheduleInfo.fromJson(json['schedule']);
    } else if (json['scheduleId'] != null) {
      parsedSchedule = EnrolmentScheduleInfo(
        id: json['scheduleId'].toString(),
        scheduleCode: json['scheduleCode']?.toString() ?? '',
      );
    }

    // Student Parsing
    EnrolmentStudentInfo? parsedStudent;
    if (json['student'] != null) {
      parsedStudent = EnrolmentStudentInfo.fromJson(json['student']);
    } else if (json['studentId'] != null) {
      parsedStudent = EnrolmentStudentInfo(
        id: json['studentId'].toString(),
        firstName: json['studentName']?.toString() ?? '',
      );
    }

    // Instructor Parsing
    EnrolmentInstructorInfo? parsedInstructor;
    if (json['instructor'] != null) {
      parsedInstructor = EnrolmentInstructorInfo.fromJson(json['instructor']);
    } else if (json['instructorId'] != null) {
      parsedInstructor = EnrolmentInstructorInfo(
        id: json['instructorId'].toString(),
        firstName: json['instructorName']?.toString() ?? '',
      );
    }

    // Package Parsing
    EnrolmentPackageInfo? parsedPackage;
    if (json['package'] != null) {
      parsedPackage = EnrolmentPackageInfo.fromJson(json['package']);
    } else if (json['packageId'] != null || json['packageName'] != null) {
      parsedPackage = EnrolmentPackageInfo(
        id: json['packageId']?.toString() ?? '',
        name: json['packageName']?.toString() ?? '',
        price: double.tryParse(json['amount']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      );
    }

    return EnrolmentModel(
      id: rawId,
      schedule: parsedSchedule,
      student: parsedStudent,
      instructor: parsedInstructor,
      package: parsedPackage,
      remarks: json['remarks']?.toString() ?? 'Enrolled by admin',
      status: json['status']?.toString() ?? 'Active',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Paid',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      rawStudentName: json['studentName']?.toString(),
      rawPackageName: json['packageName']?.toString(),
      rawEnrolmentDate: json['enrolmentDate']?.toString(),
      rawScheduleCode: json['scheduleCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'schedule': schedule?.toJson() ?? schedule?.id,
        'student': student?.toJson() ?? student?.id,
        'instructor': instructor?.toJson() ?? instructor?.id,
        'package': package?.toJson() ?? package?.id,
        'remarks': remarks,
        'status': status,
        'paymentStatus': paymentStatus,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Map<String, dynamic> toCreatePayload({
    required String scheduleId,
    required String packageId,
    required String studentId,
    String remarks = 'Enrolled by admin',
  }) {
    return {
      'scheduleId': scheduleId,
      'packageId': packageId,
      'student': studentId,
      'remarks': remarks,
    };
  }

  EnrolmentModel copyWith({
    String? id,
    EnrolmentScheduleInfo? schedule,
    EnrolmentStudentInfo? student,
    EnrolmentInstructorInfo? instructor,
    EnrolmentPackageInfo? package,
    String? remarks,
    String? status,
    String? paymentStatus,
    String? createdAt,
    String? updatedAt,
  }) {
    return EnrolmentModel(
      id: id ?? this.id,
      schedule: schedule ?? this.schedule,
      student: student ?? this.student,
      instructor: instructor ?? this.instructor,
      package: package ?? this.package,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
