class MetricCardModel {
  final String title;
  final String value;
  final String route;

  const MetricCardModel({
    required this.title,
    required this.value,
    required this.route,
  });
}

class MonthlyIncomeData {
  final String month;
  final double beginnerTraining;
  final double refresherCourses;

  const MonthlyIncomeData({
    required this.month,
    required this.beginnerTraining,
    required this.refresherCourses,
  });

  factory MonthlyIncomeData.fromJson(Map<String, dynamic> json) {
    return MonthlyIncomeData(
      month: json['month'] ?? '',
      beginnerTraining: (json['beginnerTraining'] as num?)?.toDouble() ?? 0.0,
      refresherCourses: (json['refresherCourses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'beginnerTraining': beginnerTraining,
        'refresherCourses': refresherCourses,
      };
}

class AdminDashboardModel {
  final int instructorCount;
  final int studentCount;
  final int enrolmentCount;
  final double totalIncome;
  final List<MonthlyIncomeData> monthlyIncomeData;

  const AdminDashboardModel({
    required this.instructorCount,
    required this.studentCount,
    required this.enrolmentCount,
    required this.totalIncome,
    required this.monthlyIncomeData,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final list = json['monthlyIncomeData'] as List<dynamic>? ?? [];
    return AdminDashboardModel(
      instructorCount: json['instructorCount'] ?? 0,
      studentCount: json['studentCount'] ?? 0,
      enrolmentCount: json['enrolmentCount'] ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyIncomeData: list.map((e) => MonthlyIncomeData.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'instructorCount': instructorCount,
        'studentCount': studentCount,
        'enrolmentCount': enrolmentCount,
        'totalIncome': totalIncome,
        'monthlyIncomeData': monthlyIncomeData.map((e) => e.toJson()).toList(),
      };
}
