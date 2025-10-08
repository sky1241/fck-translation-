import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import '../../../features/chat/data/models/attachment.dart';
import 'upload_service.dart';

/// Placeholder cloud uploader. To be implemented against S3/Cloudinary/etc.
class CloudUploadService implements UploadService {
  CloudUploadService({required this.endpointBase});
  final String endpointBase; // e.g., https://your-upload-api

  @override
  Stream<UploadProgress> upload(AttachmentDraft draft) async* {
    // Best-effort simple multipart upload (no chunked progress from http)
    // Emit a few synthetic steps for UX, then final URL provided by server
    yield UploadProgress(percent: 10);
    final uri = Uri.parse('$endpointBase/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', draft.sourcePath, contentType: _contentType(draft.mimeType)));
    req.fields['kind'] = draft.kind.name;
    final resp = await req.send();
    yield UploadProgress(percent: 70);
    final body = await resp.stream.bytesToString();
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // Expect a JSON like {"url": "https://..."}
      final String url = _extractUrl(body) ?? '';
      yield UploadProgress(percent: 100, remoteUrl: url.isNotEmpty ? url : null);
    } else {
      // Fallback: encode small files inline (base64) for demo mode
      try {
        final bytes = await File(draft.sourcePath).readAsBytes();
        if (bytes.lengthInBytes < 350 * 1024) {
          final b64 = 'data:${draft.mimeType};base64,' + base64Encode(bytes);
          yield UploadProgress(percent: 100, remoteUrl: null, base64Data: b64);
          return;
        }
      } catch (_) {}
      yield UploadProgress(percent: 100, remoteUrl: null);
    }
  }

  // Minimal content type mapping
  MediaType _contentType(String mime) {
    final parts = mime.split('/');
    return MediaType(parts.first, parts.length > 1 ? parts[1] : '*');
  }

  String? _extractUrl(String body) {
    final match = RegExp('"url"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1);
  }
}


