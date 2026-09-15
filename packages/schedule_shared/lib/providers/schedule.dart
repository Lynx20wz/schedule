import 'package:riverpod/riverpod.dart';
import 'package:schedule_shared/schedule_shared.dart';

/// Returns null if the token is not available.
final scheduleProvider = FutureProvider<Schedule?>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null) return null;
  final api = MySchoolApi(token);
  return await api.getSchedule();
});
