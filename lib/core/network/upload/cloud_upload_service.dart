import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  Stream<UploadProgress> uploadAudio(AudioAttachmentDraft draft) async* {
    print('[CloudUploadService] 🎤 Uploading audio file: ${draft.sourcePath}');
    yield UploadProgress(percent: 10);
    
    // For audio, fallback to base64 since audio files can be large
    if (endpointBase.isEmpty) {
      // No endpoint configured: embed as base64
      try {
        final File file = File(draft.sourcePath);
        if (await file.exists()) {
          final Uint8List bytes = await file.readAsBytes();
          print('[CloudUploadService] 🎤 Audio file size: ${bytes.length} bytes');
          
          // Check if file is small enough for base64 (e.g., < 500KB)
          if (bytes.length < 500 * 1024) {
            print('[CloudUploadService] ✅ Converting audio to base64...');
            final String b64 = 'data:audio/m4a;base64,${base64Encode(bytes)}';
            yield UploadProgress(percent: 100, base64Data: b64);
          } else {
            print('[CloudUploadService] ❌ Audio file too large for base64');
            yield UploadProgress(percent: 100);
          }
        } else {
          print('[CloudUploadService] ❌ Audio file not found');
          yield UploadProgress(percent: 100);
        }
      } catch (e) {
        print('[CloudUploadService] ❌ Error uploading audio: $e');
        yield UploadProgress(percent: 100);
      }
      return;
    }
    
    // Try to upload to server if endpoint is configured
    try {
      final Uri uri = Uri.parse('$endpointBase/upload');
      final req = http.MultipartRequest('POST', uri);
      req.files.add(await http.MultipartFile.fromPath(
        'file',
        draft.sourcePath,
        contentType: _contentType(draft.mimeType),
      ));
      req.fields['kind'] = 'audio';
      yield UploadProgress(percent: 50);
      
      final resp = await req.send();
      yield UploadProgress(percent: 80);
      final String body = await resp.stream.bytesToString();
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final String url = _extractUrl(body) ?? '';
        yield UploadProgress(percent: 100, remoteUrl: url.isNotEmpty ? url : null);
      } else {
        print('[CloudUploadService] ❌ Upload failed, no fallback for audio');
        yield UploadProgress(percent: 100);
      }
    } catch (e) {
      print('[CloudUploadService] ❌ Error during audio upload: $e');
      yield UploadProgress(percent: 100);
    }
  }

  @override
  Stream<UploadProgress> upload(AttachmentDraft draft) async* {
    // Best-effort simple multipart upload (no chunked progress from http)
    // Emit a few synthetic steps for UX, then final URL provided by server
    yield UploadProgress(percent: 10);
    if (endpointBase.isEmpty) {
      // No endpoint configured: embed small files as base64 and finish.
      try {
        print('[CloudUploadService] 🔄 Converting image to JPEG format...');
        final Uint8List? convertedBytes = await _convertToJpeg(draft.sourcePath);
        if (convertedBytes != null && convertedBytes.length < 400 * 1024) {
          print('[CloudUploadService] ✅ Converted to JPEG: ${convertedBytes.length} bytes');
          final String b64 = 'data:image/jpeg;base64,${base64Encode(convertedBytes)}';
          yield UploadProgress(percent: 100, base64Data: b64);
        } else {
          print('[CloudUploadService] ❌ Conversion failed or image too large');
          yield UploadProgress(percent: 100);
        }
      } catch (e) {
        print('[CloudUploadService] ❌ Error: $e');
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
        print('[CloudUploadService] ⚠️ Upload failed, fallback to base64...');
        final Uint8List? convertedBytes = await _convertToJpeg(draft.sourcePath);
        if (convertedBytes != null && convertedBytes.length < 400 * 1024) {
          print('[CloudUploadService] ✅ Fallback: Converted to JPEG: ${convertedBytes.length} bytes');
          final String b64 = 'data:image/jpeg;base64,${base64Encode(convertedBytes)}';
          yield UploadProgress(percent: 100, base64Data: b64);
          return;
        }
      } catch (e) {
        print('[CloudUploadService] ❌ Fallback error: $e');
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
      
      print('[CloudUploadService] 🔍 Original image size: ${bytes.length} bytes');
      
      // Decode image using `image` package (supports JPEG, PNG, GIF, BMP, TIFF, TGA, PSD, PVR, etc.)
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print('[CloudUploadService] ❌ Failed to decode image');
        return null;
      }
      
      print('[CloudUploadService] 🔍 Image decoded: ${image.width}x${image.height}');
      
      // Re-encode as JPEG with quality 60 (smaller size for WebSocket compatibility)
      final List<int> jpegBytes = img.encodeJpg(image, quality: 60);
      print('[CloudUploadService] 🔍 JPEG encoded: ${jpegBytes.length} bytes');
      
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      print('[CloudUploadService] ❌ Failed to convert image: $e');
      return null;
    }
  }
}


