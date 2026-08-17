import 'package:flutter_test/flutter_test.dart';
import 'package:dsms_dev/features/schedule/schedule_model.dart';
import 'package:dsms_dev/features/schedule/schedule_service.dart';
import 'package:dsms_dev/features/schedule/schedule_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleModel Tests', () {
    test('ScheduleModel instantiates and serializes correctly', () {
      const schedule = ScheduleModel(
        id: 'SCH-2026-999',
        scheduleCode: 'SCH-2026-999',
        date: '2026-08-20',
        time: '08:00 AM - 10:00 AM',
        instructor: 'Michael Scott',
        slotsAvailable: 4,
        totalSlots: 5,
        amount: 1500.0,
        remarks: 'Beginner Traffic & Road Rules',
        status: 'Available',
      );

      expect(schedule.scheduleCode, 'SCH-2026-999');
      expect(schedule.date, '2026-08-20');
      expect(schedule.instructor, 'Michael Scott');
      expect(schedule.slotsAvailable, 4);
      expect(schedule.amount, 1500.0);
      expect(schedule.remarks, 'Beginner Traffic & Road Rules');
      expect(schedule.isAvailable, true);
      expect(schedule.isFull, false);
      expect(schedule.formattedAmount, 'ETB 1,500.00');

      final json = schedule.toJson();
      final fromJson = ScheduleModel.fromJson(json);
      expect(fromJson.scheduleCode, schedule.scheduleCode);
      expect(fromJson.date, schedule.date);
      expect(fromJson.instructor, schedule.instructor);
      expect(fromJson.slotsAvailable, schedule.slotsAvailable);
      expect(fromJson.amount, schedule.amount);
      expect(fromJson.remarks, schedule.remarks);
    });

    test('ScheduleModel copyWith works as expected', () {
      const schedule = ScheduleModel(
        id: 'SCH-1',
        scheduleCode: 'SCH-1',
        date: '2026-08-20',
        instructor: 'Pam Beesly',
        slotsAvailable: 2,
        amount: 2000.0,
      );

      final updated = schedule.copyWith(slotsAvailable: 0, status: 'Full');
      expect(updated.slotsAvailable, 0);
      expect(updated.status, 'Full');
      expect(updated.isFull, true);
      expect(updated.isAvailable, false);
    });
  });

  group('ScheduleService & Controller CRUD Tests', () {
    test('ScheduleService generates valid schedule codes', () {
      final code = ScheduleService.generateScheduleCode();
      expect(code.startsWith('SCH-'), true);
    });

    test(
      'ScheduleController performs load, create, update, and delete in mock mode',
      () async {
        final controller = ScheduleController();
        await controller.loadSchedules();

        final initialCount = controller.totalCount;
        expect(initialCount, greaterThan(0));

        // 1. Create
        final newCode = controller.generateNextCode();
        await controller.createSchedule({
          'scheduleCode': newCode,
          'date': '2026-09-01',
          'time': '10:30 AM - 12:30 PM',
          'instructor': 'Jim Halpert',
          'slotsAvailable': 3,
          'totalSlots': 3,
          'amount': 1800.0,
          'remarks': 'Expressway training test',
          'status': 'Available',
        });

        expect(controller.totalCount, initialCount + 1);
        expect(
          controller.schedules.any((s) => s.scheduleCode == newCode),
          true,
        );

        // 2. Filter & Search
        controller.setSearchQuery(newCode);
        expect(controller.filteredSchedules.length, 1);
        expect(controller.filteredSchedules.first.scheduleCode, newCode);

        controller.setSearchQuery('');
        controller.setStatusFilter('Available');
        expect(controller.filteredSchedules.every((s) => s.isAvailable), true);
        controller.setStatusFilter('All');

        // 3. Update
        await controller.updateSchedule(newCode, {
          'id': newCode,
          'scheduleCode': newCode,
          'date': '2026-09-02',
          'time': '10:30 AM - 12:30 PM',
          'instructor': 'Jim Halpert',
          'slotsAvailable': 1,
          'totalSlots': 3,
          'amount': 1800.0,
          'remarks': 'Updated Expressway training',
          'status': 'Available',
        });

        final updatedItem = controller.schedules.firstWhere(
          (s) => s.scheduleCode == newCode,
        );
        expect(updatedItem.date, '2026-09-02');
        expect(updatedItem.slotsAvailable, 1);
        expect(updatedItem.remarks, 'Updated Expressway training');

        // 4. Delete
        await controller.deleteSchedule(newCode);
        expect(
          controller.schedules.any((s) => s.scheduleCode == newCode),
          false,
        );
        expect(controller.totalCount, initialCount);
      },
    );
  });
}
