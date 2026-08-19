class DashboardStats {
  final int instructorCount;
  final int studentCount;
  final int enrollmentCount;
  final double totalIncome;

  const DashboardStats({
    this.instructorCount = 0,
    this.studentCount = 0,
    this.enrollmentCount = 0,
    this.totalIncome = 0.0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      instructorCount: (json['instructorCount'] as num?)?.toInt() ?? 0,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      enrollmentCount: (json['enrollmentCount'] as num?)?.toInt() ??
          (json['enrolmentCount'] as num?)?.toInt() ??
          0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'instructorCount': instructorCount,
        'studentCount': studentCount,
        'enrollmentCount': enrollmentCount,
        'totalIncome': totalIncome,
      };
}

class PaymentStatusBreakdown {
  final String status;
  final int count;
  final double totalAmount;

  const PaymentStatusBreakdown({
    required this.status,
    required this.count,
    required this.totalAmount,
  });

  factory PaymentStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentStatusBreakdown(
      status: json['status']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'count': count,
        'totalAmount': totalAmount,
      };
}

class MonthlyIncome {
  final double total;
  final int year;
  final int month;

  const MonthlyIncome({
    required this.total,
    required this.year,
    required this.month,
  });

  factory MonthlyIncome.fromJson(Map<String, dynamic> json) {
    return MonthlyIncome(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
    );
  }

  String get monthName {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return 'M$month';
  }

  String get label => '$monthName $year';

  Map<String, dynamic> toJson() => {
        'total': total,
        'year': year,
        'month': month,
      };
}

class MonthlyEnrollment {
  final int count;
  final int year;
  final int month;

  const MonthlyEnrollment({
    required this.count,
    required this.year,
    required this.month,
  });

  factory MonthlyEnrollment.fromJson(Map<String, dynamic> json) {
    return MonthlyEnrollment(
      count: (json['count'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
    );
  }

  String get monthName {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return 'M$month';
  }

  String get label => '$monthName $year';

  Map<String, dynamic> toJson() => {
        'count': count,
        'year': year,
        'month': month,
      };
}

class PackagePopularity {
  final int count;
  final String packageId;
  final String packageName;

  const PackagePopularity({
    required this.count,
    required this.packageId,
    required this.packageName,
  });

  factory PackagePopularity.fromJson(Map<String, dynamic> json) {
    return PackagePopularity(
      count: (json['count'] as num?)?.toInt() ?? 0,
      packageId: json['packageId']?.toString() ?? '',
      packageName: json['packageName']?.toString() ?? 'Unknown Package',
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'packageId': packageId,
        'packageName': packageName,
      };
}

class InstructorWorkload {
  final String instructorId;
  final String firstName;
  final String lastName;
  final String username;
  final int scheduleCount;
  final int studentCount;

  const InstructorWorkload({
    required this.instructorId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.scheduleCount,
    required this.studentCount,
  });

  factory InstructorWorkload.fromJson(Map<String, dynamic> json) {
    return InstructorWorkload(
      instructorId: json['instructorId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      scheduleCount: (json['scheduleCount'] as num?)?.toInt() ?? 0,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    if (username.isNotEmpty) return username;
    return 'Instructor';
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (username.isNotEmpty) return username[0].toUpperCase();
    return 'I';
  }

  Map<String, dynamic> toJson() => {
        'instructorId': instructorId,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'scheduleCount': scheduleCount,
        'studentCount': studentCount,
      };
}

class PaymentStudent {
  final String id;
  final String firstName;
  final String lastName;
  final String username;

  const PaymentStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  factory PaymentStudent.fromJson(Map<String, dynamic> json) {
    return PaymentStudent(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    if (username.isNotEmpty) return username;
    return 'Student';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      };
}

class RecentPayment {
  final String id;
  final String referenceNo;
  final PaymentStudent? student;
  final double amount;
  final DateTime? dateOfPayment;
  final String status;
  final DateTime? createdAt;

  const RecentPayment({
    required this.id,
    required this.referenceNo,
    this.student,
    required this.amount,
    this.dateOfPayment,
    required this.status,
    this.createdAt,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return RecentPayment(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      referenceNo: json['referenceNo']?.toString() ?? '',
      student: json['student'] is Map
          ? PaymentStudent.fromJson(
              Map<String, dynamic>.from(json['student'] as Map))
          : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dateOfPayment: parseDate(json['dateOfPayment']),
      status: json['status']?.toString() ?? 'unpaid',
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referenceNo': referenceNo,
        'student': student?.toJson(),
        'amount': amount,
        'dateOfPayment': dateOfPayment?.toIso8601String(),
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}

class AdminDashboardData {
  final DashboardStats stats;
  final List<PaymentStatusBreakdown> paymentBreakdown;
  final List<MonthlyIncome> monthlyIncome;
  final List<MonthlyEnrollment> monthlyEnrollments;
  final List<PackagePopularity> packagePopularity;
  final List<InstructorWorkload> instructorWorkload;
  final List<RecentPayment> recentPayments;

  const AdminDashboardData({
    this.stats = const DashboardStats(),
    this.paymentBreakdown = const [],
    this.monthlyIncome = const [],
    this.monthlyEnrollments = const [],
    this.packagePopularity = const [],
    this.instructorWorkload = const [],
    this.recentPayments = const [],
  });
}
