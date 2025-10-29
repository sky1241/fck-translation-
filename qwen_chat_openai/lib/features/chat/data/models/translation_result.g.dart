// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranslationResult _$TranslationResultFromJson(Map<String, dynamic> json) =>
    _TranslationResult(
      translation: json['translation'] as String,
      pinyin: json['pinyin'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TranslationResultToJson(_TranslationResult instance) =>
    <String, dynamic>{
      'translation': instance.translation,
      'pinyin': instance.pinyin,
      'notes': instance.notes,
    };
