// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranslationResultImpl _$$TranslationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$TranslationResultImpl(
      translation: json['translation'] as String,
      pinyin: json['pinyin'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TranslationResultImplToJson(
        _$TranslationResultImpl instance) =>
    <String, dynamic>{
      'translation': instance.translation,
      'pinyin': instance.pinyin,
      'notes': instance.notes,
    };
