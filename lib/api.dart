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
  static const String _token =
      'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIzNjE3NTkwIiwic2NwIjoib3BlbmlkIHByb2ZpbGUiLCJtc2giOiJkZDBlNjA0NC0xMzhjLTRlNTItODlhYi1mMmEwZGE5YzliN2MiLCJpc3MiOiJodHRwczpcL1wvYXV0aGVkdS5tb3NyZWcucnUiLCJyb2wiOiIiLCJzc28iOiIxMDkxMDQwNjYwIiwiYXVkIjoiMjoxIiwibmJmIjoxNzYzNzQ1MjkyLCJhdGgiOiJlc2lhIiwicmxzIjoiezE6WzIwOjI6W10sMzA6NDpbXSw0MDoxOltdLDE4MzoxNjpbXSwyMTE6MTk6W10sNTMzOjQ4OltdXX0iLCJyZ24iOiI1MCIsImV4cCI6MTc2NDYwOTI4NywiaWF0IjoxNzYzNzQ1MjkyLCJqdGkiOiI5Y2ZhYTRkNi01MDI2LTRhZmYtYmFhNC1kNjUwMjY1YWZmMTEifQ.N70us9CwYA9StQsaDqhmFKLJEZ5fIF2zlcLD2H12KV6s-uowfNTWAQobJFGd6EbWb-crZwUeQbiqRtco81g39jl0XiM35DVVz4dYR2xdD-q0fCr7hkmo8bGYq24bPw2F1y61U-p8jjSy9avprtxCHzBHq1SGbSJP6TCuI44SFb0gQWiCN-NXJWgsjApSdKBGVI1I3kF7V5jvv4ExlKduZlzxzU1im2p46cPC7z6v49MA92MsrYTwYuowKpa_N0cI3rVU4gWfSnVY9R3vXkm4pRB17sze0W4UUFa687vU3od7pLy9vVQuCfurXx1Mm7ybefhiINv3kbYUmXrT17Uu1w';
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
