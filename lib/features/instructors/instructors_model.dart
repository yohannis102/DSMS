class InstructorsModel {
  final String id;
  final String name;
  final String vehicleType;
  final int totalStudents;

  const InstructorsModel({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.totalStudents,
  });

  factory InstructorsModel.fromJson(Map<String, dynamic> json) => InstructorsModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        vehicleType: json['vehicleType'] ?? 'Manual',
        totalStudents: json['totalStudents'] ?? 0,
      );
}
