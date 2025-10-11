import 'package:freezed_annotation/freezed_annotation.dart';
import 'attachment.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String originalText,
    required String translatedText,
    required bool isMe,
    required DateTime time,
    String? pinyin,
    String? notes,
    @AttachmentListConverter() @Default(<Attachment>[]) List<Attachment> attachments,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

class AttachmentListConverter
    implements JsonConverter<List<Attachment>, List<dynamic>> {
  const AttachmentListConverter();

  @override
  List<Attachment> fromJson(List<dynamic> json) {
    return json
        .whereType<Map<String, Object?>>()
        .map(Attachment.fromJson)
        .toList(growable: false);
  }

  @override
  List<dynamic> toJson(List<Attachment> object) {
    return object.map((a) => a.toJson()).toList(growable: false);
  }
}


