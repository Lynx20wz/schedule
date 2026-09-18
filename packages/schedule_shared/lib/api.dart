import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:schedule_shared/schedule_shared.dart';

final Dio dio = Dio();

class MySchoolApi {
  static final DateTime _mondayDay = _getMondayDate(DateTime.now());

  static DateTime _getMondayDate(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static String _formatDay(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static const String _baseUrl = 'https://authedu.mosreg.ru/api';
  static const String _studentId = 'dd0e6044-138c-4e52-89ab-f2a0da9c9b7c';

  final String token;
  const MySchoolApi(this.token);

  Map<String, String> get _headers => {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
    'Authorization': 'Bearer $token',
    'Connection': 'keep-alive',
    'Content-Type': 'application/json;charset=UTF-8',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    'X-Mes-Role': 'student',
    'X-mes-subsystem': 'familyweb',
    'sec-ch-ua':
        '"Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"',
  };

  Future<Schedule?> getSchedule() async {
    Map<String, dynamic> params = {
      'person_ids': _studentId,
      'begin_date': _formatDay(_mondayDay),
      'end_date': _formatDay(_mondayDay.add(const Duration(days: 5))),
      'expand': 'marks,absence_reason_id',
    };
    try {
      final response = await dio.get(
        '$_baseUrl/eventcalendar/v1/api/events',
        queryParameters: params,
        options: Options(headers: _headers),
      );

      log(
        'Schedule:\nfrom ${params['begin_date']}\nto ${params['end_date']}\n$response',
        name: 'API request (getSchedule)',
      );

      return Schedule.fromMap(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('Failed to get schedule: $e', name: 'API request (getSchedule)');
      return null;
    }
  }
}
