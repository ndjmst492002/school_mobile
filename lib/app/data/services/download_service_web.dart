import 'dart:html' as html;
import 'dart:typed_data';
import 'package:dio/dio.dart';

class DownloadService {
  static Future<void> downloadFile({
    required Dio dio,
    required String url,
    String? filename,
    String? fileUrl,
  }) async {
    // On web, use the download endpoint via anchor click
    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        extra: {'withCredentials': true},
      ),
      data: null,
    );

    if (response.statusCode != 200) {
      final body = response.data is List<int>
          ? String.fromCharCodes(response.data as List<int>)
          : response.data.toString();
      throw Exception('Download failed with status ${response.statusCode}: $body');
    }

    final contentType = response.headers.value('content-type') ?? 'application/octet-stream';
    final name = filename ?? _extractFilename(response) ?? 'download';
    final data = response.data;

    html.Blob blob;
    if (data is Uint8List) {
      blob = html.Blob([data], contentType);
    } else if (data is List<int>) {
      blob = html.Blob([Uint8List.fromList(data)], contentType);
    } else {
      throw Exception('Unexpected response type: ${data.runtimeType}');
    }

    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: objectUrl)
      ..target = 'download'
      ..download = name;
    anchor.click();
    html.Url.revokeObjectUrl(objectUrl);
  }

  static String? _extractFilename(Response response) {
    final disposition = response.headers.value('content-disposition');
    if (disposition == null) return null;
    final match = RegExp(r'filename[^;=\n]*=([^;\n]+)').firstMatch(disposition);
    if (match == null) return null;
    return match.group(1)?.trim().replaceAll('"', '');
  }
}
