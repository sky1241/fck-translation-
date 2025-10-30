import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../features/chat/data/models/attachment.dart';

class AttachmentPickerService {
  AttachmentPickerService() : _picker = ImagePicker();
  final ImagePicker _picker;

  Future<AttachmentDraft?> pickImage() async {
    final XFile? x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return null;
    // image_picker may not provide MIME; best-effort guess
    final String mime = _guessMime(x.path, fallback: 'image/jpeg');
    int? size;
    try {
      size = await x.length();
    } catch (_) {
      size = null;
    }
    return AttachmentDraft(
      kind: AttachmentKind.image,
      sourcePath: x.path,
      mimeType: mime,
      estimatedBytes: size,
    );
  }

  /// Prendre une photo avec la caméra
  Future<AttachmentDraft?> pickImageFromCamera() async {
    final XFile? x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return null;
    final String mime = _guessMime(x.path, fallback: 'image/jpeg');
    int? size;
    try {
      size = await x.length();
    } catch (_) {
      size = null;
    }
    return AttachmentDraft(
      kind: AttachmentKind.image,
      sourcePath: x.path,
      mimeType: mime,
      estimatedBytes: size,
    );
  }

  /// Prendre une vidéo avec la caméra
  Future<AttachmentDraft?> pickVideoFromCamera() async {
    final XFile? x = await _picker.pickVideo(source: ImageSource.camera);
    if (x == null) return null;
    int? size;
    try {
      size = await x.length();
    } catch (_) {
      size = null;
    }
    return AttachmentDraft(
      kind: AttachmentKind.video,
      sourcePath: x.path,
      mimeType: 'video/mp4',
      estimatedBytes: size,
    );
  }

  // Placeholder for future video support
  Future<AttachmentDraft?> pickVideo() async {
    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return null;
    int? size;
    try {
      size = await x.length();
    } catch (_) {
      size = null;
    }
    return AttachmentDraft(
      kind: AttachmentKind.video,
      sourcePath: x.path,
      mimeType: 'video/mp4',
      estimatedBytes: size,
    );
  }

  /// Créer un draft depuis un fichier existant (pour audio)
  Future<AttachmentDraft?> pickFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final String mime = _guessMime(filePath, fallback: 'audio/m4a');
    int? size;
    try {
      size = await file.length();
    } catch (_) {
      size = null;
    }
    return AttachmentDraft(
      kind: AttachmentKind.audio,
      sourcePath: filePath,
      mimeType: mime,
      estimatedBytes: size,
    );
  }

  /// Alias pour pickImageFromCamera
  Future<AttachmentDraft?> pickCameraImage() => pickImageFromCamera();

  /// Alias pour pickVideoFromCamera
  Future<AttachmentDraft?> pickCameraVideo() => pickVideoFromCamera();

  String _guessMime(String path, {required String fallback}) {
    final String p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    if (p.endsWith('.m4a') || p.endsWith('.aac')) return 'audio/m4a';
    if (p.endsWith('.mp4')) return 'video/mp4';
    return fallback;
  }
}


