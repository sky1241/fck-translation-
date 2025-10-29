// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {
  String get id;
  String get originalText;
  String get translatedText;
  bool get isMe;
  DateTime get time;
  String? get pinyin;
  String? get notes;
  @AttachmentListConverter()
  List<Attachment> get attachments;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatMessage &&
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
                .equals(other.attachments, attachments));
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
      const DeepCollectionEquality().hash(attachments));

  @override
  String toString() {
    return 'ChatMessage(id: $id, originalText: $originalText, translatedText: $translatedText, isMe: $isMe, time: $time, pinyin: $pinyin, notes: $notes, attachments: $attachments)';
  }
}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) _then) =
      _$ChatMessageCopyWithImpl;
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
class _$ChatMessageCopyWithImpl<$Res> implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _self.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      translatedText: null == translatedText
          ? _self.translatedText
          : translatedText // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _self.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pinyin: freezed == pinyin
          ? _self.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _self.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Attachment>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChatMessage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChatMessage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChatMessage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String originalText,
            String translatedText,
            bool isMe,
            DateTime time,
            String? pinyin,
            String? notes,
            @AttachmentListConverter() List<Attachment> attachments)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(
            _that.id,
            _that.originalText,
            _that.translatedText,
            _that.isMe,
            _that.time,
            _that.pinyin,
            _that.notes,
            _that.attachments);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String originalText,
            String translatedText,
            bool isMe,
            DateTime time,
            String? pinyin,
            String? notes,
            @AttachmentListConverter() List<Attachment> attachments)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
        return $default(
            _that.id,
            _that.originalText,
            _that.translatedText,
            _that.isMe,
            _that.time,
            _that.pinyin,
            _that.notes,
            _that.attachments);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String originalText,
            String translatedText,
            bool isMe,
            DateTime time,
            String? pinyin,
            String? notes,
            @AttachmentListConverter() List<Attachment> attachments)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(
            _that.id,
            _that.originalText,
            _that.translatedText,
            _that.isMe,
            _that.time,
            _that.pinyin,
            _that.notes,
            _that.attachments);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatMessage implements ChatMessage {
  const _ChatMessage(
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
  factory _ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

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

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatMessageCopyWith<_ChatMessage> get copyWith =>
      __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatMessage &&
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

  @override
  String toString() {
    return 'ChatMessage(id: $id, originalText: $originalText, translatedText: $translatedText, isMe: $isMe, time: $time, pinyin: $pinyin, notes: $notes, attachments: $attachments)';
  }
}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(
          _ChatMessage value, $Res Function(_ChatMessage) _then) =
      __$ChatMessageCopyWithImpl;
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
class __$ChatMessageCopyWithImpl<$Res> implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_ChatMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _self.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      translatedText: null == translatedText
          ? _self.translatedText
          : translatedText // ignore: cast_nullable_to_non_nullable
              as String,
      isMe: null == isMe
          ? _self.isMe
          : isMe // ignore: cast_nullable_to_non_nullable
              as bool,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pinyin: freezed == pinyin
          ? _self.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _self._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Attachment>,
    ));
  }
}

// dart format on
