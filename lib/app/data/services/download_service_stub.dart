import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  static Future<void> downloadFile({
    required Dio dio,
    required String url,
    String? filename,
    String? fileUrl,
  }) async {
    debugPrint('Download: using API endpoint: $url');
    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        String errorBody = 'Unknown error';
        if (response.data is List<int>) {
          try {
            errorBody = utf8.decode(response.data as List<int>);
          } catch (_) {
            errorBody =
                'Binary data (${(response.data as List<int>).length} bytes)';
          }
        } else if (response.data is String) {
          errorBody = response.data as String;
        } else if (response.data != null) {
          errorBody = response.data.toString();
        }
        debugPrint('Download error body: $errorBody');
        throw Exception(
            'Download failed with status ${response.statusCode}: $errorBody');
      }

      final data = response.data;
      if (data == null) throw Exception('Empty response');

      final bytes = data is List<int> ? data : List<int>.from(data as List);
      final dir = Directory.systemTemp;

      final name = filename ?? 'download';
      final base = name.contains('.')
          ? name.substring(0, name.lastIndexOf('.'))
          : name;
      final ext = name.contains('.')
          ? '.${name.split('.').last}'
          : '.bin';
      final filePath =
          '${dir.path}/${base}_${DateTime.now().millisecondsSinceEpoch}$ext';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }
    } on DioException catch (e) {
      debugPrint(
          'Download DioException: type=${e.type}, status=${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired');
      }
      rethrow;
    }
  }
}
