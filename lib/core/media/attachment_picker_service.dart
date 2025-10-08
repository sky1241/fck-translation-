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
    return AttachmentDraft(
      kind: AttachmentKind.image,
      sourcePath: x.path,
      mimeType: mime,
      estimatedBytes: await x.length().catchError((_) => null),
    );
  }

  // Placeholder for future video support
  Future<AttachmentDraft?> pickVideo() async {
    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return null;
    return AttachmentDraft(
      kind: AttachmentKind.video,
      sourcePath: x.path,
      mimeType: 'video/mp4',
      estimatedBytes: await x.length().catchError((_) => null),
    );
  }

  String _guessMime(String path, {required String fallback}) {
    final String p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    return fallback;
  }
}


