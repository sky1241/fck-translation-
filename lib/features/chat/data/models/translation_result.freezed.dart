// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TranslationResult _$TranslationResultFromJson(Map<String, dynamic> json) {
  return _TranslationResult.fromJson(json);
}

/// @nodoc
mixin _$TranslationResult {
  String get translation => throw _privateConstructorUsedError;
  String? get pinyin => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this TranslationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationResultCopyWith<TranslationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationResultCopyWith<$Res> {
  factory $TranslationResultCopyWith(
          TranslationResult value, $Res Function(TranslationResult) then) =
      _$TranslationResultCopyWithImpl<$Res, TranslationResult>;
  @useResult
  $Res call({String translation, String? pinyin, String? notes});
}

/// @nodoc
class _$TranslationResultCopyWithImpl<$Res, $Val extends TranslationResult>
    implements $TranslationResultCopyWith<$Res> {
  _$TranslationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translation = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      pinyin: freezed == pinyin
          ? _value.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationResultImplCopyWith<$Res>
    implements $TranslationResultCopyWith<$Res> {
  factory _$$TranslationResultImplCopyWith(_$TranslationResultImpl value,
          $Res Function(_$TranslationResultImpl) then) =
      __$$TranslationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String translation, String? pinyin, String? notes});
}

/// @nodoc
class __$$TranslationResultImplCopyWithImpl<$Res>
    extends _$TranslationResultCopyWithImpl<$Res, _$TranslationResultImpl>
    implements _$$TranslationResultImplCopyWith<$Res> {
  __$$TranslationResultImplCopyWithImpl(_$TranslationResultImpl _value,
      $Res Function(_$TranslationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translation = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$TranslationResultImpl(
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      pinyin: freezed == pinyin
          ? _value.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationResultImpl implements _TranslationResult {
  const _$TranslationResultImpl(
      {required this.translation, this.pinyin, this.notes});

  factory _$TranslationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationResultImplFromJson(json);

  @override
  final String translation;
  @override
  final String? pinyin;
  @override
  final String? notes;

  @override
  String toString() {
    return 'TranslationResult(translation: $translation, pinyin: $pinyin, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationResultImpl &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.pinyin, pinyin) || other.pinyin == pinyin) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, translation, pinyin, notes);

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationResultImplCopyWith<_$TranslationResultImpl> get copyWith =>
      __$$TranslationResultImplCopyWithImpl<_$TranslationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationResultImplToJson(
      this,
    );
  }
}

abstract class _TranslationResult implements TranslationResult {
  const factory _TranslationResult(
      {required final String translation,
      final String? pinyin,
      final String? notes}) = _$TranslationResultImpl;

  factory _TranslationResult.fromJson(Map<String, dynamic> json) =
      _$TranslationResultImpl.fromJson;

  @override
  String get translation;
  @override
  String? get pinyin;
  @override
  String? get notes;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationResultImplCopyWith<_$TranslationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
