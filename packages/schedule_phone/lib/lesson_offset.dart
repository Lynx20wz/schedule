import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Duration maxLessonOffset = Duration(minutes: 5);

final lessonOffsetProvider =
    AsyncNotifierProvider<LessonOffsetNotifier, Duration>(
      LessonOffsetNotifier.new,
    );

class LessonOffsetNotifier extends AsyncNotifier<Duration> {
  static const _prefsKey = 'lesson_offset_seconds';

  @override
  Future<Duration> build() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_prefsKey) ?? 0;
    return _clamp(Duration(seconds: seconds));
  }

  Future<void> set(Duration value) async {
    final offset = _clamp(value);
    state = AsyncData(offset);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, offset.inSeconds);
  }

  Duration _clamp(Duration value) {
    final maxSeconds = maxLessonOffset.inSeconds;
    final seconds = value.inSeconds.clamp(-maxSeconds, maxSeconds);
    return Duration(seconds: seconds.toInt());
  }
}
