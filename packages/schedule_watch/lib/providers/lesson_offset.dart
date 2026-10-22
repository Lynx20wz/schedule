import 'package:riverpod/riverpod.dart';

const Duration maxLessonOffset = Duration(minutes: 5);

final lessonOffsetProvider = NotifierProvider<LessonOffsetNotifier, Duration>(
  LessonOffsetNotifier.new,
);

class LessonOffsetNotifier extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;

  void set(Duration value) {
    final maxSeconds = maxLessonOffset.inSeconds;
    final seconds = value.inSeconds.clamp(-maxSeconds, maxSeconds);
    state = Duration(seconds: seconds.toInt());
  }
}
