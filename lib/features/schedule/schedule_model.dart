class ScheduleModel {
  final String id;
  final String title;
  final String date;
  final String time;
  final String instructor;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.instructor,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        instructor: json['instructor'] ?? '',
      );
}
