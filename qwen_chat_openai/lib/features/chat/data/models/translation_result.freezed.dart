// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranslationResult {
  String get translation;
  String? get pinyin;
  String? get notes;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TranslationResultCopyWith<TranslationResult> get copyWith =>
      _$TranslationResultCopyWithImpl<TranslationResult>(
          this as TranslationResult, _$identity);

  /// Serializes this TranslationResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TranslationResult &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.pinyin, pinyin) || other.pinyin == pinyin) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, translation, pinyin, notes);

  @override
  String toString() {
    return 'TranslationResult(translation: $translation, pinyin: $pinyin, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $TranslationResultCopyWith<$Res> {
  factory $TranslationResultCopyWith(
          TranslationResult value, $Res Function(TranslationResult) _then) =
      _$TranslationResultCopyWithImpl;
  @useResult
  $Res call({String translation, String? pinyin, String? notes});
}

/// @nodoc
class _$TranslationResultCopyWithImpl<$Res>
    implements $TranslationResultCopyWith<$Res> {
  _$TranslationResultCopyWithImpl(this._self, this._then);

  final TranslationResult _self;
  final $Res Function(TranslationResult) _then;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translation = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      translation: null == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      pinyin: freezed == pinyin
          ? _self.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TranslationResult].
extension TranslationResultPatterns on TranslationResult {
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
    TResult Function(_TranslationResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TranslationResult() when $default != null:
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
    TResult Function(_TranslationResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TranslationResult():
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
    TResult? Function(_TranslationResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TranslationResult() when $default != null:
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
    TResult Function(String translation, String? pinyin, String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TranslationResult() when $default != null:
        return $default(_that.translation, _that.pinyin, _that.notes);
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
    TResult Function(String translation, String? pinyin, String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TranslationResult():
        return $default(_that.translation, _that.pinyin, _that.notes);
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
    TResult? Function(String translation, String? pinyin, String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TranslationResult() when $default != null:
        return $default(_that.translation, _that.pinyin, _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TranslationResult implements TranslationResult {
  const _TranslationResult(
      {required this.translation, this.pinyin, this.notes});
  factory _TranslationResult.fromJson(Map<String, dynamic> json) =>
      _$TranslationResultFromJson(json);

  @override
  final String translation;
  @override
  final String? pinyin;
  @override
  final String? notes;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TranslationResultCopyWith<_TranslationResult> get copyWith =>
      __$TranslationResultCopyWithImpl<_TranslationResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TranslationResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TranslationResult &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.pinyin, pinyin) || other.pinyin == pinyin) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, translation, pinyin, notes);

  @override
  String toString() {
    return 'TranslationResult(translation: $translation, pinyin: $pinyin, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$TranslationResultCopyWith<$Res>
    implements $TranslationResultCopyWith<$Res> {
  factory _$TranslationResultCopyWith(
          _TranslationResult value, $Res Function(_TranslationResult) _then) =
      __$TranslationResultCopyWithImpl;
  @override
  @useResult
  $Res call({String translation, String? pinyin, String? notes});
}

/// @nodoc
class __$TranslationResultCopyWithImpl<$Res>
    implements _$TranslationResultCopyWith<$Res> {
  __$TranslationResultCopyWithImpl(this._self, this._then);

  final _TranslationResult _self;
  final $Res Function(_TranslationResult) _then;

  /// Create a copy of TranslationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? translation = null,
    Object? pinyin = freezed,
    Object? notes = freezed,
  }) {
    return _then(_TranslationResult(
      translation: null == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      pinyin: freezed == pinyin
          ? _self.pinyin
          : pinyin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
