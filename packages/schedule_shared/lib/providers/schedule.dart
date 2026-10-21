import 'package:riverpod/riverpod.dart';
import 'package:schedule_shared/exceptions.dart';
import 'package:schedule_shared/schedule_shared.dart';

final scheduleProvider = FutureProvider<Schedule>(
  (ref) async {
    final token = ref.watch(tokenProvider);
    if (token == null) throw const TokenNotFound();
    final api = MySchoolApi(token);
    return await api.getSchedule();
  },
  retry: (retryCount, error) => error is TokenException || retryCount >= 5
      ? null
      : ProviderContainer.defaultRetry(retryCount, error),
);
