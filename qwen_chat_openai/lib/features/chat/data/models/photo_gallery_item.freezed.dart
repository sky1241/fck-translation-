// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_gallery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhotoGalleryItem _$PhotoGalleryItemFromJson(Map<String, dynamic> json) {
  return _PhotoGalleryItem.fromJson(json);
}

/// @nodoc
mixin _$PhotoGalleryItem {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError; // URL cloud
  String? get localPath =>
      throw _privateConstructorUsedError; // Chemin local (cache)
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isFromMe =>
      throw _privateConstructorUsedError; // Photo envoyée par moi ou reçue
  String? get thumbnail =>
      throw _privateConstructorUsedError; // URL du thumbnail
  int? get fileSize => throw _privateConstructorUsedError; // Taille en bytes
  PhotoStatus get status => throw _privateConstructorUsedError;

  /// Serializes this PhotoGalleryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoGalleryItemCopyWith<PhotoGalleryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoGalleryItemCopyWith<$Res> {
  factory $PhotoGalleryItemCopyWith(
          PhotoGalleryItem value, $Res Function(PhotoGalleryItem) then) =
      _$PhotoGalleryItemCopyWithImpl<$Res, PhotoGalleryItem>;
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
class _$PhotoGalleryItemCopyWithImpl<$Res, $Val extends PhotoGalleryItem>
    implements $PhotoGalleryItemCopyWith<$Res> {
  _$PhotoGalleryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFromMe: null == isFromMe
          ? _value.isFromMe
          : isFromMe // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PhotoStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoGalleryItemImplCopyWith<$Res>
    implements $PhotoGalleryItemCopyWith<$Res> {
  factory _$$PhotoGalleryItemImplCopyWith(_$PhotoGalleryItemImpl value,
          $Res Function(_$PhotoGalleryItemImpl) then) =
      __$$PhotoGalleryItemImplCopyWithImpl<$Res>;
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
class __$$PhotoGalleryItemImplCopyWithImpl<$Res>
    extends _$PhotoGalleryItemCopyWithImpl<$Res, _$PhotoGalleryItemImpl>
    implements _$$PhotoGalleryItemImplCopyWith<$Res> {
  __$$PhotoGalleryItemImplCopyWithImpl(_$PhotoGalleryItemImpl _value,
      $Res Function(_$PhotoGalleryItemImpl) _then)
      : super(_value, _then);

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
    return _then(_$PhotoGalleryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFromMe: null == isFromMe
          ? _value.isFromMe
          : isFromMe // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PhotoStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoGalleryItemImpl implements _PhotoGalleryItem {
  const _$PhotoGalleryItemImpl(
      {required this.id,
      required this.url,
      this.localPath,
      required this.timestamp,
      required this.isFromMe,
      this.thumbnail,
      this.fileSize,
      this.status = PhotoStatus.remote});

  factory _$PhotoGalleryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoGalleryItemImplFromJson(json);

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

  @override
  String toString() {
    return 'PhotoGalleryItem(id: $id, url: $url, localPath: $localPath, timestamp: $timestamp, isFromMe: $isFromMe, thumbnail: $thumbnail, fileSize: $fileSize, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoGalleryItemImpl &&
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

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoGalleryItemImplCopyWith<_$PhotoGalleryItemImpl> get copyWith =>
      __$$PhotoGalleryItemImplCopyWithImpl<_$PhotoGalleryItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoGalleryItemImplToJson(
      this,
    );
  }
}

abstract class _PhotoGalleryItem implements PhotoGalleryItem {
  const factory _PhotoGalleryItem(
      {required final String id,
      required final String url,
      final String? localPath,
      required final DateTime timestamp,
      required final bool isFromMe,
      final String? thumbnail,
      final int? fileSize,
      final PhotoStatus status}) = _$PhotoGalleryItemImpl;

  factory _PhotoGalleryItem.fromJson(Map<String, dynamic> json) =
      _$PhotoGalleryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get url; // URL cloud
  @override
  String? get localPath; // Chemin local (cache)
  @override
  DateTime get timestamp;
  @override
  bool get isFromMe; // Photo envoyée par moi ou reçue
  @override
  String? get thumbnail; // URL du thumbnail
  @override
  int? get fileSize; // Taille en bytes
  @override
  PhotoStatus get status;

  /// Create a copy of PhotoGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoGalleryItemImplCopyWith<_$PhotoGalleryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
