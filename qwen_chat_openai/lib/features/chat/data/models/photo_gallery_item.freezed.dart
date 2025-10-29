// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_gallery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoGalleryItem {
  String get id;
  String get url; // URL cloud
  String? get localPath; // Chemin local (cache)
  DateTime get timestamp;
  bool get isFromMe; // Photo envoyée par moi ou reçue
  String? get thumbnail; // URL du thumbnail
  int? get fileSize; // Taille en bytes
  PhotoStatus get status;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PhotoGalleryItemCopyWith<PhotoGalleryItem> get copyWith =>
      _$PhotoGalleryItemCopyWithImpl<PhotoGalleryItem>(
          this as PhotoGalleryItem, _$identity);

  /// Serializes this PhotoGalleryItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PhotoGalleryItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isFromMe, isFromMe) ||
                other.isFromMe == isFromMe) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, localPath, timestamp,
      isFromMe, thumbnail, fileSize, status);

  @override
  String toString() {
    return 'PhotoGalleryItem(id: $id, url: $url, localPath: $localPath, timestamp: $timestamp, isFromMe: $isFromMe, thumbnail: $thumbnail, fileSize: $fileSize, status: $status)';
  }
}

/// @nodoc
abstract mixin class $PhotoGalleryItemCopyWith<$Res> {
  factory $PhotoGalleryItemCopyWith(
          PhotoGalleryItem value, $Res Function(PhotoGalleryItem) _then) =
      _$PhotoGalleryItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String url,
      String? localPath,
      DateTime timestamp,
      bool isFromMe,
      String? thumbnail,
      int? fileSize,
      PhotoStatus status});
}

/// @nodoc
class _$PhotoGalleryItemCopyWithImpl<$Res>
    implements $PhotoGalleryItemCopyWith<$Res> {
  _$PhotoGalleryItemCopyWithImpl(this._self, this._then);

  final PhotoGalleryItem _self;
  final $Res Function(PhotoGalleryItem) _then;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? localPath = freezed,
    Object? timestamp = null,
    Object? isFromMe = null,
    Object? thumbnail = freezed,
    Object? fileSize = freezed,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: freezed == localPath
          ? _self.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFromMe: null == isFromMe
          ? _self.isFromMe
          : isFromMe // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as PhotoStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [PhotoGalleryItem].
extension PhotoGalleryItemPatterns on PhotoGalleryItem {
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
    TResult Function(_PhotoGalleryItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem() when $default != null:
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
    TResult Function(_PhotoGalleryItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem():
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
    TResult? Function(_PhotoGalleryItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem() when $default != null:
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
            String url,
            String? localPath,
            DateTime timestamp,
            bool isFromMe,
            String? thumbnail,
            int? fileSize,
            PhotoStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem() when $default != null:
        return $default(_that.id, _that.url, _that.localPath, _that.timestamp,
            _that.isFromMe, _that.thumbnail, _that.fileSize, _that.status);
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
            String url,
            String? localPath,
            DateTime timestamp,
            bool isFromMe,
            String? thumbnail,
            int? fileSize,
            PhotoStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem():
        return $default(_that.id, _that.url, _that.localPath, _that.timestamp,
            _that.isFromMe, _that.thumbnail, _that.fileSize, _that.status);
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
            String url,
            String? localPath,
            DateTime timestamp,
            bool isFromMe,
            String? thumbnail,
            int? fileSize,
            PhotoStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoGalleryItem() when $default != null:
        return $default(_that.id, _that.url, _that.localPath, _that.timestamp,
            _that.isFromMe, _that.thumbnail, _that.fileSize, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PhotoGalleryItem implements PhotoGalleryItem {
  const _PhotoGalleryItem(
      {required this.id,
      required this.url,
      this.localPath,
      required this.timestamp,
      required this.isFromMe,
      this.thumbnail,
      this.fileSize,
      this.status = PhotoStatus.remote});
  factory _PhotoGalleryItem.fromJson(Map<String, dynamic> json) =>
      _$PhotoGalleryItemFromJson(json);

  @override
  final String id;
  @override
  final String url;
// URL cloud
  @override
  final String? localPath;
// Chemin local (cache)
  @override
  final DateTime timestamp;
  @override
  final bool isFromMe;
// Photo envoyée par moi ou reçue
  @override
  final String? thumbnail;
// URL du thumbnail
  @override
  final int? fileSize;
// Taille en bytes
  @override
  @JsonKey()
  final PhotoStatus status;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PhotoGalleryItemCopyWith<_PhotoGalleryItem> get copyWith =>
      __$PhotoGalleryItemCopyWithImpl<_PhotoGalleryItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PhotoGalleryItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PhotoGalleryItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isFromMe, isFromMe) ||
                other.isFromMe == isFromMe) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, localPath, timestamp,
      isFromMe, thumbnail, fileSize, status);

  @override
  String toString() {
    return 'PhotoGalleryItem(id: $id, url: $url, localPath: $localPath, timestamp: $timestamp, isFromMe: $isFromMe, thumbnail: $thumbnail, fileSize: $fileSize, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$PhotoGalleryItemCopyWith<$Res>
    implements $PhotoGalleryItemCopyWith<$Res> {
  factory _$PhotoGalleryItemCopyWith(
          _PhotoGalleryItem value, $Res Function(_PhotoGalleryItem) _then) =
      __$PhotoGalleryItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String? localPath,
      DateTime timestamp,
      bool isFromMe,
      String? thumbnail,
      int? fileSize,
      PhotoStatus status});
}

/// @nodoc
class __$PhotoGalleryItemCopyWithImpl<$Res>
    implements _$PhotoGalleryItemCopyWith<$Res> {
  __$PhotoGalleryItemCopyWithImpl(this._self, this._then);

  final _PhotoGalleryItem _self;
  final $Res Function(_PhotoGalleryItem) _then;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? localPath = freezed,
    Object? timestamp = null,
    Object? isFromMe = null,
    Object? thumbnail = freezed,
    Object? fileSize = freezed,
    Object? status = null,
  }) {
    return _then(_PhotoGalleryItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: freezed == localPath
          ? _self.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFromMe: null == isFromMe
          ? _self.isFromMe
          : isFromMe // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as PhotoStatus,
    ));
  }
}

// dart format on
