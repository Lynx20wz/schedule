import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'package:intl/intl.dart' show DateFormat;

final Dio dio = Dio();

class Parser {
  static final DateTime _mondayDay = _getMondayDate(DateTime.now());

  static DateTime _getMondayDate(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static String _formatDay({DateTime? date}) =>
      DateFormat('yyyy-MM-dd').format(date ?? _mondayDay);

  static const String _baseUrl = 'https://authedu.mosreg.ru/api';
  static const String _studentId = 'dd0e6044-138c-4e52-89ab-f2a0da9c9b7c';

  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
    'Authorization': 'Bearer $token',
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

  final String token;
  Parser(this.token);

  Future<Map<String, dynamic>> getSchedule() async {
    Map<String, dynamic> params = {
      'person_ids': _studentId,
      'begin_date': _formatDay(),
      'end_date': _formatDay(date: _mondayDay.add(const Duration(days: 5))),
      'expand': 'marks',
    };
    try {
      var response = await dio.get(
        '$_baseUrl/eventcalendar/v1/api/events',
        queryParameters: params,
        options: Options(headers: _headers),
      );
      log(
        'Schedule:\nfrom ${params['begin_date']}\nto ${params['end_date']}\n$response',
        name: 'API request info',
      );

      return response.data;
    } on DioException {
      return {};
    }
  }
}
