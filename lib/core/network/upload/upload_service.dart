import '../../../features/chat/data/models/attachment.dart';

abstract class UploadService {
  Stream<UploadProgress> upload(AttachmentDraft draft);
  
  /// Upload audio files (voice messages)
  Stream<UploadProgress> uploadAudio(AudioAttachmentDraft draft) {
    // Par défaut, convertir en AttachmentDraft et utiliser upload
    return upload(draft.toAttachmentDraft());
  }
}

class UploadProgress {
  UploadProgress({required this.percent, this.remoteUrl, this.base64Data});
  final double percent; // 0.0 .. 100.0
  final String? remoteUrl;
  final String? base64Data; // used for base64 relay mode
}


