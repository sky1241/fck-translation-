import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_result.freezed.dart';
part 'translation_result.g.dart';

@freezed
class TranslationResult with _$TranslationResult {
  const factory TranslationResult({
    required String translation,
    String? pinyin,
    String? notes,
  }) = _TranslationResult;

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      _$TranslationResultFromJson(json);
}


