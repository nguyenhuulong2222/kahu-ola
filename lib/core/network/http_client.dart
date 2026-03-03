import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';

Dio buildHttpClient({required String appVersion}) {
  return Dio(
    BaseOptions(
      baseUrl: Env.aggregatorBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, Object>{
        'Accept': 'application/json',
        'X-App-Version': appVersion,
        'X-Platform': defaultTargetPlatform.name,
        'X-Region': 'maui',
      },
      responseType: ResponseType.json,
    ),
  );
}
