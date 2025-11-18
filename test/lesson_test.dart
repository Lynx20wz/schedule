import 'package:schedule/classes/lesson.dart';
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
}
