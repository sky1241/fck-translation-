import 'dart:convert';

/// Minimal attachment model to support images/videos with both local cache and remote URL
/// and a simple lifecycle status for UI updates (progress, done, failed).
class Attachment {
  const Attachment({
    required this.id,
    required this.kind,
    required this.mimeType,
    this.remoteUrl,
    this.localPath,
    this.thumbnailPath,
    this.width,
    this.height,
    this.sizeBytes,
    required this.createdAt,
    this.status = AttachmentStatus.pending,
  });

  final String id;
  final AttachmentKind kind;
  final String mimeType;
  final String? remoteUrl; // Preferred for rendering when present
  final String? localPath; // Cached file on device (download/upload temp)
  final String? thumbnailPath; // Local thumbnail path if available
  final int? width;
  final int? height;
  final int? sizeBytes;
  final DateTime createdAt;
  final AttachmentStatus status;

  Attachment copyWith({
    String? id,
    AttachmentKind? kind,
    String? mimeType,
    String? remoteUrl,
    String? localPath,
    String? thumbnailPath,
    int? width,
    int? height,
    int? sizeBytes,
    DateTime? createdAt,
    AttachmentStatus? status,
  }) {
    return Attachment(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      mimeType: mimeType ?? this.mimeType,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'kind': kind.name,
      'mime': mimeType,
      'remoteUrl': remoteUrl,
      'localPath': localPath,
      'thumb': thumbnailPath,
      'w': width,
      'h': height,
      'size': sizeBytes,
      'ts': createdAt.toUtc().toIso8601String(),
      'status': status.name,
    };
  }

  static Attachment fromJson(Map<String, Object?> map) {
    return Attachment(
      id: map['id'] as String,
      kind: AttachmentKind.values.firstWhere((e) => e.name == map['kind']),
      mimeType: map['mime'] as String,
      remoteUrl: map['remoteUrl'] as String?,
      localPath: map['localPath'] as String?,
      thumbnailPath: map['thumb'] as String?,
      width: map['w'] as int?,
      height: map['h'] as int?,
      sizeBytes: map['size'] as int?,
      createdAt: DateTime.parse(map['ts'] as String).toUtc(),
      status: AttachmentStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => AttachmentStatus.pending),
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

enum AttachmentKind { image, video }

enum AttachmentStatus { pending, uploading, uploaded, failed }

/// Draft produced by the picker before compression/upload
class AttachmentDraft {
  AttachmentDraft({
    required this.kind,
    required this.sourcePath,
    required this.mimeType,
    this.estimatedBytes,
  });

  final AttachmentKind kind;
  final String sourcePath;
  final String mimeType;
  final int? estimatedBytes;
}


