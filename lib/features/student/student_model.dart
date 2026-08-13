class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        status: json['status'] ?? 'Active',
      );
}
