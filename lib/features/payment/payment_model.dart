import 'dart:convert';
import 'package:flutter/material.dart';

/// Nested schedule info in payment enrollment
class PaymentScheduleInfo {
  final String id;
  final String scheduleCode;
  final String date;

  const PaymentScheduleInfo({
    required this.id,
    this.scheduleCode = '',
    this.date = '',
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
    return 'N/A';
  }

  factory PaymentScheduleInfo.fromJson(dynamic json) {
    if (json == null) return const PaymentScheduleInfo(id: '');
    if (json is String) return PaymentScheduleInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return PaymentScheduleInfo(
        id: (map['_id'] ?? map['id'])?.toString() ?? '',
        scheduleCode: (map['scheduleCode'] ?? map['code'])?.toString() ?? '',
        date: map['date']?.toString() ?? '',
      );
    }
    return const PaymentScheduleInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'scheduleCode': scheduleCode,
        'date': date,
      };
}

/// Nested enrollment info in payment
class PaymentEnrollmentInfo {
  final String id;
  final PaymentScheduleInfo schedule;
  final String studentId;
  final String instructorId;

  const PaymentEnrollmentInfo({
    required this.id,
    this.schedule = const PaymentScheduleInfo(id: ''),
    this.studentId = '',
    this.instructorId = '',
  });

  factory PaymentEnrollmentInfo.fromJson(dynamic json) {
    if (json == null) return const PaymentEnrollmentInfo(id: '');
    if (json is String) return PaymentEnrollmentInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return PaymentEnrollmentInfo(
        id: (map['_id'] ?? map['id'])?.toString() ?? '',
        schedule: PaymentScheduleInfo.fromJson(map['schedule']),
        studentId: map['student'] is Map
            ? ((map['student'] as Map)['_id']?.toString() ?? '')
            : (map['student']?.toString() ?? ''),
        instructorId: map['instructor'] is Map
            ? ((map['instructor'] as Map)['_id']?.toString() ?? '')
            : (map['instructor']?.toString() ?? ''),
      );
    }
    return const PaymentEnrollmentInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'schedule': schedule.toJson(),
        'student': studentId,
        'instructor': instructorId,
      };
}

/// Nested student info in payment
class PaymentStudentInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;

  const PaymentStudentInfo({
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
    return id.isNotEmpty ? 'Student ($id)' : 'Unknown Student';
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

  factory PaymentStudentInfo.fromJson(dynamic json) {
    if (json == null) return const PaymentStudentInfo(id: '');
    if (json is String) return PaymentStudentInfo(id: json);
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json as Map);
      return PaymentStudentInfo(
        id: (map['_id'] ?? map['id'])?.toString() ?? '',
        firstName: map['firstName']?.toString() ?? '',
        lastName: map['lastName']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        username: map['username']?.toString() ?? '',
      );
    }
    return const PaymentStudentInfo(id: '');
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
      };
}

/// Main Payment Model
class PaymentModel {
  final String id;
  final String referenceNo;
  final PaymentEnrollmentInfo enrollment;
  final PaymentStudentInfo student;
  final double amount;
  final String dateOfPayment;
  final String status;
  final String remarks;
  final String proofOfPayment;
  final String createdAt;
  final String updatedAt;

  const PaymentModel({
    required this.id,
    this.referenceNo = '',
    this.enrollment = const PaymentEnrollmentInfo(id: ''),
    this.student = const PaymentStudentInfo(id: ''),
    this.amount = 0.0,
    this.dateOfPayment = '',
    this.status = 'unpaid',
    this.remarks = '',
    this.proofOfPayment = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isPaid => status.trim().toLowerCase() == 'paid';

  Color get statusColor {
    return isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706);
  }

  Color get statusBgColor {
    return isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
  }

  String get formattedAmount {
    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} ETB';
  }

  String get formattedDate {
    final rawDate = dateOfPayment.isNotEmpty
        ? dateOfPayment
        : (createdAt.isNotEmpty ? createdAt : '');
    if (rawDate.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(rawDate);
    if (dt != null) {
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return rawDate;
  }

  String get formattedTime {
    final rawDate = dateOfPayment.isNotEmpty
        ? dateOfPayment
        : (createdAt.isNotEmpty ? createdAt : '');
    if (rawDate.contains('T')) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        final hour = dt.hour;
        final minute = dt.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final h12 = hour % 12 == 0 ? 12 : hour % 12;
        return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    }
    return '';
  }

  factory PaymentModel.fromJson(dynamic rawJson) {
    final Map<String, dynamic> json = rawJson is String
        ? (jsonDecode(rawJson) as Map<String, dynamic>? ?? {})
        : (rawJson is Map ? Map<String, dynamic>.from(rawJson) : {});

    // Fallbacks for older dummy models
    final id = (json['_id'] ?? json['id'] ?? json['transactionId'])?.toString() ?? '';
    final ref = (json['referenceNo'] ?? json['transactionId'] ?? '')?.toString() ?? '';
    
    // Amount handling
    final num? rawAmount = json['amount'] is num
        ? json['amount'] as num
        : num.tryParse(json['amount']?.toString() ?? '');
    final double amount = rawAmount?.toDouble() ?? 0.0;

    // Student fallback
    PaymentStudentInfo student;
    if (json['student'] != null) {
      student = PaymentStudentInfo.fromJson(json['student']);
    } else if (json['studentName'] != null) {
      final sName = json['studentName'].toString();
      student = PaymentStudentInfo(id: '', firstName: sName);
    } else {
      student = const PaymentStudentInfo(id: '');
    }

    // Enrollment fallback
    final enrollment = PaymentEnrollmentInfo.fromJson(json['enrollment']);

    return PaymentModel(
      id: id,
      referenceNo: ref,
      enrollment: enrollment,
      student: student,
      amount: amount,
      dateOfPayment: (json['dateOfPayment'] ?? json['date'])?.toString() ?? '',
      status: (json['status'] ?? 'unpaid')?.toString() ?? 'unpaid',
      remarks: json['remarks']?.toString() ?? '',
      proofOfPayment: (json['proofOfPayment'] ?? json['proof'] ?? '')?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'referenceNo': referenceNo,
        'enrollment': enrollment.toJson(),
        'student': student.toJson(),
        'amount': amount,
        'dateOfPayment': dateOfPayment,
        'status': status,
        'remarks': remarks,
        'proofOfPayment': proofOfPayment,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  PaymentModel copyWith({
    String? id,
    String? referenceNo,
    PaymentEnrollmentInfo? enrollment,
    PaymentStudentInfo? student,
    double? amount,
    String? dateOfPayment,
    String? status,
    String? remarks,
    String? proofOfPayment,
    String? createdAt,
    String? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      referenceNo: referenceNo ?? this.referenceNo,
      enrollment: enrollment ?? this.enrollment,
      student: student ?? this.student,
      amount: amount ?? this.amount,
      dateOfPayment: dateOfPayment ?? this.dateOfPayment,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      proofOfPayment: proofOfPayment ?? this.proofOfPayment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
