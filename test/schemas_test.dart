import 'package:schedule/classes/lesson.dart';
import 'package:schedule/classes/schedule.dart';
import 'package:test/test.dart';

void main() {
  group('Lesson', () {
    test('should create Lesson from valid JSON with timezone', () {
      const json = {
        'subject_name': 'Math',
        'room_number': '101',
        'start_at': '2024-01-01T09:00:00+03:00',
        'finish_at': '2024-01-01T12:10:30+03:00',
      };

      final lesson = Lesson.fromMap(json);

      expect(lesson.name, 'Math');
      expect(lesson.room, '101');
      expect(lesson.startAt, DateTime.utc(2024, 1, 1, 6, 0));
      expect(lesson.finishAt, DateTime.utc(2024, 1, 1, 9, 10, 30));
    });
  });

  group('Schedule', () {
    test('should create Schedule with lessons with timezone', () {
      const json = {
        'total_count': 2,
        'response': [
          {
            'subject_name': 'Math',
            'room_number': '101',
            'start_at': '2024-01-01T09:00:00+03:00',
            'finish_at': '2024-01-01T10:30:00+03:00',
          },
          {
            'subject_name': 'Physics',
            'room_number': '202',
            'start_at': '2024-01-01T11:00:00+03:00',
            'finish_at': '2024-01-01T12:30:00+03:00',
          },
        ],
      };

      final Schedule schedule = Schedule.fromMap(json);

      expect(schedule.totalCount, 2);
      expect(schedule.lessons, hasLength(2));
      expect(schedule.lessons[0].name, 'Math');
      expect(schedule.lessons[1].name, 'Physics');
      expect(
        schedule.lessons[0].startAt,
        DateTime.utc(2024, 1, 1, 6, 0),
      ); // UTC
      expect(
        schedule.lessons[1].startAt,
        DateTime.utc(2024, 1, 1, 8, 0),
      ); // UTC
    });

    test('days test', () {
      const json = {
        'total_count': 2,
        'response': [
          {
            'subject_name': 'Math',
            'room_number': '101',
            'start_at': '2024-01-01T09:00:00+03:00',
            'finish_at': '2024-01-01T10:30:00+03:00',
          },
          {
            'subject_name': 'Physics',
            'room_number': '202',
            'start_at': '2024-01-02T11:00:00+03:00',
            'finish_at': '2024-01-02T12:30:00+03:00',
          },
        ],
      };

      final schedule = Schedule.fromMap(json);

      expect(schedule.days, {
        'monday': [schedule.lessons[0]],
        'tuesday': [schedule.lessons[1]],
        'wednesday': [],
        'thursday': [],
        'friday': [],
        'saturday': [],
        'sunday': [],
      });
    });
  });
}
