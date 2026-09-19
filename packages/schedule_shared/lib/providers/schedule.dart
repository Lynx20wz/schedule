import 'package:riverpod/riverpod.dart';
import 'package:schedule_shared/exceptions.dart';
import 'package:schedule_shared/schedule_shared.dart';

final scheduleProvider = FutureProvider<Schedule>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null) throw TokenInvalidException();
  final api = MySchoolApi(token);
  return await api.getSchedule();
});
