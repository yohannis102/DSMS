class PaymentModel {
  final String transactionId;
  final String studentName;
  final double amount;
  final String date;
  final String method;

  const PaymentModel({
    required this.transactionId,
    required this.studentName,
    required this.amount,
    required this.date,
    required this.method,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        transactionId: json['transactionId'] ?? '',
        studentName: json['studentName'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        method: json['method'] ?? 'Bank Transfer',
      );
}
