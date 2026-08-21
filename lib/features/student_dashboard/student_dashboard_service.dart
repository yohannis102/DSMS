import '../instructors/instructors_model.dart';
import '../instructors/instructors_service.dart';
import '../schedule/schedule_model.dart';
import '../schedule/schedule_service.dart';

class StudentDashboardData {
  final List<InstructorsModel> instructors;
  final List<ScheduleModel> schedules;

  const StudentDashboardData({
    this.instructors = const [],
    this.schedules = const [],
  });

  int get totalInstructors => instructors.length;
  int get totalSchedules => schedules.length;

  int get availableSchedulesCount =>
      schedules.where((s) => s.isAvailable).length;

  int get activeInstructorsCount => instructors
      .where((i) => i.accountStatus.toLowerCase() == 'active')
      .length;
}

class StudentDashboardService {
  final InstructorsService _instructorsService = InstructorsService();
  final ScheduleService _scheduleService = ScheduleService();

  Future<StudentDashboardData> fetchDashboardData({
    bool forceRefresh = false,
  }) async {
    // Fetch instructors and schedules in parallel
    final results = await Future.wait([
      _instructorsService
          .fetchInstructors(forceRefresh: forceRefresh)
          .catchError((_) => <InstructorsModel>[]),
      _scheduleService
          .fetchSchedules(forceRefresh: forceRefresh)
          .catchError((_) => <ScheduleModel>[]),
    ]);

    final instructors = results[0] as List<InstructorsModel>;
    final schedules = results[1] as List<ScheduleModel>;

    return StudentDashboardData(
      instructors: instructors,
      schedules: schedules,
    );
  }
}
