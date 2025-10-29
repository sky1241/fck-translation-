// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get originalText => throw _privateConstructorUsedError;
  String get translatedText => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;
  DateTime get time => throw _privateConstructorUsedError;
  String? get pinyin => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @AttachmentListConverter()
  List<Attachment> get attachments => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      String originalText,
      String translatedText,
      bool isMe,
      DateTime time,
      String? pinyin,
      String? notes,
      @AttachmentListConverter() List<Attachment> attachments});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? translatedText = null,
    Object? isMe = null,
    Object? time = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      translatedText: null == translatedText
          ? _value.translatedText
          : translatedText // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _value.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pinyin: freezed == pinyin
          ? _value.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Attachment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String originalText,
      String translatedText,
      bool isMe,
      DateTime time,
      String? pinyin,
      String? notes,
      @AttachmentListConverter() List<Attachment> attachments});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? translatedText = null,
    Object? isMe = null,
    Object? time = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
    Object? attachments = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      translatedText: null == translatedText
          ? _value.translatedText
          : translatedText // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _value.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pinyin: freezed == pinyin
          ? _value.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Attachment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.originalText,
      required this.translatedText,
      required this.isMe,
      required this.time,
      this.pinyin,
      this.notes,
      @AttachmentListConverter()
      final List<Attachment> attachments = const <Attachment>[]})
      : _attachments = attachments;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String originalText;
  @override
  final String translatedText;
  @override
  final bool isMe;
  @override
  final DateTime time;
  @override
  final String? pinyin;
  @override
  final String? notes;
  final List<Attachment> _attachments;
  @override
  @JsonKey()
  @AttachmentListConverter()
  List<Attachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, originalText: $originalText, translatedText: $translatedText, isMe: $isMe, time: $time, pinyin: $pinyin, notes: $notes, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalText, originalText) ||
                other.originalText == originalText) &&
            (identical(other.translatedText, translatedText) ||
                other.translatedText == translatedText) &&
            (identical(other.isMe, isMe) || other.isMe == isMe) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.pinyin, pinyin) || other.pinyin == pinyin) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      originalText,
      translatedText,
      isMe,
      time,
      pinyin,
      notes,
      const DeepCollectionEquality().hash(_attachments));

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
          {required final String id,
          required final String originalText,
          required final String translatedText,
          required final bool isMe,
          required final DateTime time,
          final String? pinyin,
          final String? notes,
          @AttachmentListConverter() final List<Attachment> attachments}) =
      _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get originalText;
  @override
  String get translatedText;
  @override
  bool get isMe;
  @override
  DateTime get time;
  @override
  String? get pinyin;
  @override
  String? get notes;
  @override
  @AttachmentListConverter()
  List<Attachment> get attachments;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
