import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image/image.dart' as img;
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
    if (endpointBase.isEmpty) {
      // No endpoint configured: embed small files as base64 and finish.
      try {
        if (kDebugMode) debugPrint('[CloudUploadService] 🔄 Converting image to JPEG format...');
        final Uint8List? convertedBytes = await _convertToJpeg(draft.sourcePath);
        if (convertedBytes != null && convertedBytes.length < 400 * 1024) {
          if (kDebugMode) debugPrint('[CloudUploadService] ✅ Converted to JPEG: ${convertedBytes.length} bytes');
          final String b64 = 'data:image/jpeg;base64,${base64Encode(convertedBytes)}';
          yield UploadProgress(percent: 100, base64Data: b64);
        } else {
          if (kDebugMode) debugPrint('[CloudUploadService] ❌ Conversion failed or image too large');
          yield UploadProgress(percent: 100);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[CloudUploadService] ❌ Error: $e');
        yield UploadProgress(percent: 100);
      }
      return;
    }

    final Uri uri = Uri.parse('$endpointBase/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath(
      'file',
      draft.sourcePath,
      contentType: _contentType(draft.mimeType),
    ));
    req.fields['kind'] = draft.kind.name;
    final resp = await req.send();
    yield UploadProgress(percent: 70);
    final String body = await resp.stream.bytesToString();
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final String url = _extractUrl(body) ?? '';
      yield UploadProgress(percent: 100, remoteUrl: url.isNotEmpty ? url : null);
    } else {
      // Upload failed: fallback to base64
      try {
        if (kDebugMode) debugPrint('[CloudUploadService] ⚠️ Upload failed, fallback to base64...');
        final Uint8List? convertedBytes = await _convertToJpeg(draft.sourcePath);
        if (convertedBytes != null && convertedBytes.length < 400 * 1024) {
          if (kDebugMode) debugPrint('[CloudUploadService] ✅ Fallback: Converted to JPEG: ${convertedBytes.length} bytes');
          final String b64 = 'data:image/jpeg;base64,${base64Encode(convertedBytes)}';
          yield UploadProgress(percent: 100, base64Data: b64);
          return;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[CloudUploadService] ❌ Fallback error: $e');
      }
      yield UploadProgress(percent: 100);
    }
  }

  // Minimal content type mapping
  MediaType _contentType(String mime) {
    final parts = mime.split('/');
    return MediaType(parts.first, parts.length > 1 ? parts[1] : '*');
  }

  String? _extractUrl(String body) {
    final match = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1);
  }

  /// Convert any image format to JPEG bytes (Skia-compatible)
  Future<Uint8List?> _convertToJpeg(String filePath) async {
    try {
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      if (kDebugMode) debugPrint('[CloudUploadService] 🔍 Original image size: ${bytes.length} bytes');
      
      // Decode image using `image` package (supports JPEG, PNG, GIF, BMP, TIFF, TGA, PSD, PVR, etc.)
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        if (kDebugMode) debugPrint('[CloudUploadService] ❌ Failed to decode image');
        return null;
      }
      
      if (kDebugMode) debugPrint('[CloudUploadService] 🔍 Image decoded: ${image.width}x${image.height}');
      
      // Re-encode as JPEG with quality 60 (smaller size for WebSocket compatibility)
      final List<int> jpegBytes = img.encodeJpg(image, quality: 60);
      if (kDebugMode) debugPrint('[CloudUploadService] 🔍 JPEG encoded: ${jpegBytes.length} bytes');
      
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      if (kDebugMode) debugPrint('[CloudUploadService] ❌ Failed to convert image: $e');
      return null;
    }
  }
}


