// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_problem.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FieldProblemCWProxy {
  FieldProblem code(String code);

  FieldProblem field(String field);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FieldProblem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FieldProblem(...).copyWith(id: 12, name: "My name")
  /// ````
  FieldProblem call({String code, String field});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFieldProblem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFieldProblem.copyWith.fieldName(...)`
class _$FieldProblemCWProxyImpl implements _$FieldProblemCWProxy {
  const _$FieldProblemCWProxyImpl(this._value);

  final FieldProblem _value;

  @override
  FieldProblem code(String code) => this(code: code);

  @override
  FieldProblem field(String field) => this(field: field);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FieldProblem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FieldProblem(...).copyWith(id: 12, name: "My name")
  /// ````
  FieldProblem call({
    Object? code = const $CopyWithPlaceholder(),
    Object? field = const $CopyWithPlaceholder(),
  }) {
    return FieldProblem(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      field: field == const $CopyWithPlaceholder()
          ? _value.field
          // ignore: cast_nullable_to_non_nullable
          : field as String,
    );
  }
}

extension $FieldProblemCopyWith on FieldProblem {
  /// Returns a callable class that can be used as follows: `instanceOfFieldProblem.copyWith(...)` or like so:`instanceOfFieldProblem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FieldProblemCWProxy get copyWith => _$FieldProblemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldProblem _$FieldProblemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FieldProblem', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'field']);
      final val = FieldProblem(
        code: $checkedConvert('code', (v) => v as String),
        field: $checkedConvert('field', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$FieldProblemToJson(FieldProblem instance) =>
    <String, dynamic>{'code': instance.code, 'field': instance.field};
