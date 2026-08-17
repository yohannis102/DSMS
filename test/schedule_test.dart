import 'package:dio/dio.dart';
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
        instructorId: 'ins-123',
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
      expect(schedule.instructorId, 'ins-123');
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
      expect(fromJson.instructorId, schedule.instructorId);
      expect(fromJson.slotsAvailable, schedule.slotsAvailable);
      expect(fromJson.amount, schedule.amount);
      expect(fromJson.remarks, schedule.remarks);
    });

    test(
      'ScheduleModel parses backend API response with nested instructor object and ISO date',
      () {
        final backendJson = {
          '_id': '6a82f6accd0cd07e2458540b',
          'scheduleCode': 'SCHD-5AW4QZ',
          'date': '2026-09-01T09:00:00.000Z',
          'instructor': {
            '_id': '6a82f418cd0cd07e2458540a',
            'firstName': 'Juan',
            'lastName': 'Cruz',
            'email': 'juan.delacruz@example.com',
            'username': 'juandelacruz',
          },
          'slotsAvailable': 7,
          'amount': 4000,
          'remarks': 'Rescheduled',
          'createdAt': '2026-08-17T11:55:24.797Z',
          'updatedAt': '2026-08-17T13:01:21.270Z',
          '__v': 0,
        };

        final schedule = ScheduleModel.fromJson(backendJson);
        expect(schedule.id, '6a82f6accd0cd07e2458540b');
        expect(schedule.scheduleCode, 'SCHD-5AW4QZ');
        expect(schedule.date, '2026-09-01');
        expect(schedule.instructorId, '6a82f418cd0cd07e2458540a');
        expect(schedule.instructor, 'Juan Cruz');
        expect(schedule.instructorEmail, 'juan.delacruz@example.com');
        expect(schedule.instructorUsername, 'juandelacruz');
        expect(schedule.slotsAvailable, 7);
        expect(schedule.amount, 4000.0);
        expect(schedule.remarks, 'Rescheduled');
      },
    );

    test('ScheduleModel copyWith works as expected', () {
      const schedule = ScheduleModel(
        id: 'SCH-1',
        scheduleCode: 'SCH-1',
        date: '2026-08-20',
        instructorId: 'ins-001',
        instructor: 'Pam Beesly',
        slotsAvailable: 2,
        amount: 2000.0,
      );

      final updated = schedule.copyWith(slotsAvailable: 0, status: 'Full');
      expect(updated.slotsAvailable, 0);
      expect(updated.status, 'Full');
      expect(updated.isFull, true);
      expect(updated.isAvailable, false);
      expect(updated.instructorId, 'ins-001');
    });
  });

  group('ScheduleService & Error Extraction Tests', () {
    test('ScheduleService generates valid schedule codes', () {
      final code = ScheduleService.generateScheduleCode();
      expect(code.startsWith('SCH-'), true);
    });

    test(
      'ScheduleService extracts express-validator errors correctly',
      () {
        final service = ScheduleService();
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/schedules'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/schedules'),
            statusCode: 400,
            data: {
              'errors': [
                {
                  'type': 'field',
                  'value': 'test test',
                  'msg': 'A valid instructor id is required',
                  'path': 'instructor',
                  'location': 'body',
                },
              ],
            },
          ),
        );

        final msg = service.extractErrorMessage(dioException);
        expect(msg, 'A valid instructor id is required');
      },
    );

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
          'instructorId': '6a82f418cd0cd07e2458540a',
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
          'instructorId': '6a82f418cd0cd07e2458540a',
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
