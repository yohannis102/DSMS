class EnrolmentModel {
  final String enrolmentId;
  final String studentName;
  final String packageName;
  final String enrolmentDate;
  final String paymentStatus;

  const EnrolmentModel({
    required this.enrolmentId,
    required this.studentName,
    required this.packageName,
    required this.enrolmentDate,
    required this.paymentStatus,
  });

  factory EnrolmentModel.fromJson(Map<String, dynamic> json) => EnrolmentModel(
        enrolmentId: json['enrolmentId'] ?? '',
        studentName: json['studentName'] ?? '',
        packageName: json['packageName'] ?? '',
        enrolmentDate: json['enrolmentDate'] ?? '',
        paymentStatus: json['paymentStatus'] ?? 'Paid',
      );
}
