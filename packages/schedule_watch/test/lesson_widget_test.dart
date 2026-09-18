import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule_shared/classes/classes.dart';
import 'package:schedule_watch/widgets/lesson_widget.dart';

extension LessonMock on Lesson {
  static Lesson mock({
    String name = 'Math',
    String room = '101',
    DateTime? startAt,
    DateTime? finishAt,
    List<Mark> marks = const [],
    AbsenceReason absenceReason = AbsenceReason.none,
  }) => Lesson(
    name: name,
    room: room,
    startAt: startAt ?? DateTime.now(),
    finishAt: finishAt ?? DateTime.now().add(const Duration(minutes: 45)),
    marks: marks,
    absenceReason: absenceReason,
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
    expect(decoration.color, Colors.blueAccent);
  });
}
