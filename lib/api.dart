import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'package:intl/intl.dart' show DateFormat;

final Dio dio = Dio();

class Parser {
  static final DateTime _currentDay = DateTime.now();
  // static final DateTime _currentDay = DateTime(2025, 11, 10); // TODO for tests!
  static String _formatDay({DateTime? date}) =>
      DateFormat('yyyy-MM-dd').format(date ?? _currentDay);

  static const String _baseUrl = 'https://authedu.mosreg.ru/api';
  static const String _studentId = 'dd0e6044-138c-4e52-89ab-f2a0da9c9b7c';
  static const String _token =
      'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIzNjE3NTkwIiwic2NwIjoib3BlbmlkIHByb2ZpbGUiLCJtc2giOiJkZDBlNjA0NC0xMzhjLTRlNTItODlhYi1mMmEwZGE5YzliN2MiLCJpc3MiOiJodHRwczpcL1wvYXV0aGVkdS5tb3NyZWcucnUiLCJyb2wiOiIiLCJzc28iOiIxMDkxMDQwNjYwIiwiYXVkIjoiMjoxIiwibmJmIjoxNzYyODY4OTA2LCJhdGgiOiJlc2lhIiwicmxzIjoiezE6WzIwOjI6W10sMzA6NDpbXSw0MDoxOltdLDE4MzoxNjpbXSwyMTE6MTk6W10sNTMzOjQ4OltdXX0iLCJyZ24iOiI1MCIsImV4cCI6MTc2MzczMjg5OCwiaWF0IjoxNzYyODY4OTA2LCJqdGkiOiJjMjM2ZDA4OC0zMDIyLTRhODMtYjZkMC04ODMwMjIxYTgzMzkifQ.Ug2sGyDlPDzW2Rm3tnWNuS7TzRBb0VqX2zK5sm7iIAz4J_ktWD3D_D0OiMtzRHRTcL7rr54Do2YvAWVaISrf86SDQSQZvkTysKU0C01I5WClTUkLvPaulF6gvB3S3M6IJ9uX6srGH6dfDhPD4hSfnpo1mNUR5jokCOtQ9FAX2_VSGALnED79UrlwJysH2gn884hOPseZirW_fz1iorl1NWP6WEFqBPgX8z1ruch_cl8NBXv9I9zFZd7WtIMANZEeh2h34uLlHWh13pxhY4_JOu8wfOCWwTMm6mFnRvH49bTP4OX61joagC3oflwsseYLCqKzilfqAhMKaXzddhUZKA';
  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
    'Authorization': 'Bearer $_token',
    'Connection': 'keep-alive',
    'Content-Type': 'application/json;charset=UTF-8',
    'DNT': '1',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-origin',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    'X-Mes-Role': 'student',
    'X-mes-subsystem': 'familyweb',
    'sec-ch-ua':
        '"Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
  };

  Future<Map<String, dynamic>> getSchedule() async {
    Map<String, dynamic> params = {
      'person_ids': _studentId,
      'begin_date': _formatDay(),
      'end_date': _formatDay(date: _currentDay.add(const Duration(days: 5))),
      'expand': 'marks',
    };
    var response = await dio.get(
      '$_baseUrl/eventcalendar/v1/api/events',
      queryParameters: params,
      options: Options(headers: _headers),
    );
    log(
      'Schedule:\nfrom ${params['begin_date']}\nto ${params['end_date']}\n$response',
    );

    return response.data;
  }
}
