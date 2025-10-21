// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_gallery_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoGalleryItemImpl _$$PhotoGalleryItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PhotoGalleryItemImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      localPath: json['localPath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromMe: json['isFromMe'] as bool,
      thumbnail: json['thumbnail'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$PhotoStatusEnumMap, json['status']) ??
          PhotoStatus.remote,
    );

Map<String, dynamic> _$$PhotoGalleryItemImplToJson(
        _$PhotoGalleryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'localPath': instance.localPath,
      'timestamp': instance.timestamp.toIso8601String(),
      'isFromMe': instance.isFromMe,
      'thumbnail': instance.thumbnail,
      'fileSize': instance.fileSize,
      'status': _$PhotoStatusEnumMap[instance.status]!,
    };

const _$PhotoStatusEnumMap = {
  PhotoStatus.cached: 'cached',
  PhotoStatus.remote: 'remote',
  PhotoStatus.downloading: 'downloading',
  PhotoStatus.error: 'error',
};
