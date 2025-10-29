// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String,
      isMe: json['isMe'] as bool,
      time: DateTime.parse(json['time'] as String),
      pinyin: json['pinyin'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] == null
          ? const <Attachment>[]
          : const AttachmentListConverter()
              .fromJson(json['attachments'] as List),
    );

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalText': instance.originalText,
      'translatedText': instance.translatedText,
      'isMe': instance.isMe,
      'time': instance.time.toIso8601String(),
      'pinyin': instance.pinyin,
      'notes': instance.notes,
      'attachments':
          const AttachmentListConverter().toJson(instance.attachments),
    };
