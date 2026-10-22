import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule_shared/classes/classes.dart';
import 'package:schedule_watch/widgets/lesson_widget.dart';

extension LessonMock on Lesson {
  static Lesson mock({
    int id = 1,
    String name = 'Math',
    String room = '101',
    List<Mark> marks = const [],
    AbsenceReason absenceReason = AbsenceReason.none,
    DateTime? startAt,
    DateTime? finishAt,
  }) => Lesson(
    id: id,
    name: name,
    room: room,
    marks: marks,
    absenceReason: absenceReason,
    startAt: startAt ?? DateTime.now(),
    finishAt: finishAt ?? DateTime.now().add(const Duration(minutes: 45)),
  );
}

void main() {
  group('LessonWidget lesson with', () {
    testWidgets('no marks', (tester) async {
      final lesson = LessonMock.mock();

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('with 1 mark', (tester) async {
      final lesson = LessonMock.mock(marks: [Mark('5')]);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('with 2 marks', (tester) async {
      final lesson = LessonMock.mock(marks: [Mark('5'), Mark('4')]);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text('5|4'), findsOneWidget);
    });

    testWidgets('with 3 marks', (tester) async {
      final lesson = LessonMock.mock(marks: [Mark('5'), Mark('4'), Mark('5')]);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text('5|4|5'), findsOneWidget);
    });
  });

  group('LessonWidget absenceReason', () {
    testWidgets('LessonWidget sick', (tester) async {
      final lesson = LessonMock.mock(absenceReason: .sick);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text('Б'), findsOneWidget);
    });
    testWidgets('LessonWidget absent', (tester) async {
      final lesson = LessonMock.mock(absenceReason: .absent);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LessonWidget(lesson))),
      );

      expect(find.text('Н'), findsOneWidget);
    });
  });

  testWidgets('LessonWidget changes color for current lesson', (tester) async {
    final currentLesson = LessonMock.mock();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: LessonWidget(currentLesson))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.indigo.shade300);
  });

  testWidgets('LessonWidget stops being current after lesson finishes', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1, 10);
    final lesson = LessonMock.mock(
      startAt: DateTime(2026, 1, 1, 10),
      finishAt: DateTime(2026, 1, 1, 10, 45),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LessonWidget(lesson, now: () => now)),
      ),
    );

    var container = tester.widget<Container>(find.byType(Container));
    var decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.indigo.shade300);

    now = DateTime(2026, 1, 1, 10, 46);
    await tester.pump(const Duration(minutes: 46));

    container = tester.widget<Container>(find.byType(Container));
    decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNot(Colors.indigo.shade300));
  });

  group('Lesson.isCurrentAt', () {
    final lesson = LessonMock.mock(
      startAt: DateTime(2026, 1, 1, 10),
      finishAt: DateTime(2026, 1, 1, 10, 45),
    );

    test('is false before the lesson starts', () {
      expect(lesson.isCurrentAt(DateTime(2026, 1, 1, 9, 59)), isFalse);
    });

    test('is true at the start and inside the lesson', () {
      expect(lesson.isCurrentAt(DateTime(2026, 1, 1, 10)), isTrue);
      expect(lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 30)), isTrue);
    });

    test('is false at and after the finish time', () {
      expect(lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 45)), isFalse);
      expect(lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 46)), isFalse);
    });

    test('applies a negative offset to both boundaries', () {
      const offset = Duration(seconds: -87);

      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 9, 58, 32), offset: offset),
        isFalse,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 9, 58, 33), offset: offset),
        isTrue,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 43, 32), offset: offset),
        isTrue,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 43, 33), offset: offset),
        isFalse,
      );
    });

    test('applies a positive offset to both boundaries', () {
      const offset = Duration(seconds: 87);

      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 1, 26), offset: offset),
        isFalse,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 1, 27), offset: offset),
        isTrue,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 46, 26), offset: offset),
        isTrue,
      );
      expect(
        lesson.isCurrentAt(DateTime(2026, 1, 1, 10, 46, 27), offset: offset),
        isFalse,
      );
    });
  });

  testWidgets('LessonWidget uses the offset when lesson ends', (tester) async {
    var now = DateTime(2026, 1, 1, 10);
    final lesson = LessonMock.mock(
      startAt: DateTime(2026, 1, 1, 10),
      finishAt: DateTime(2026, 1, 1, 10, 45),
    );
    const offset = Duration(seconds: -87);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonWidget(lesson, offset: offset, now: () => now),
        ),
      ),
    );

    var container = tester.widget<Container>(find.byType(Container));
    var decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.indigo.shade300);

    now = DateTime(2026, 1, 1, 10, 43, 34);
    await tester.pump(const Duration(minutes: 44));

    container = tester.widget<Container>(find.byType(Container));
    decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNot(Colors.indigo.shade300));
  });
}
