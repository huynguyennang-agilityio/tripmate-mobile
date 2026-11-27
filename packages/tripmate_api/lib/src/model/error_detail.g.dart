// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ErrorDetailCWProxy {
  ErrorDetail code(String code);

  ErrorDetail fields(List<FieldProblem>? fields);

  ErrorDetail params(Map<String, Object> params);

  ErrorDetail requestId(String requestId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorDetail call({
    String code,
    List<FieldProblem>? fields,
    Map<String, Object> params,
    String requestId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfErrorDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfErrorDetail.copyWith.fieldName(...)`
class _$ErrorDetailCWProxyImpl implements _$ErrorDetailCWProxy {
  const _$ErrorDetailCWProxyImpl(this._value);

  final ErrorDetail _value;

  @override
  ErrorDetail code(String code) => this(code: code);

  @override
  ErrorDetail fields(List<FieldProblem>? fields) => this(fields: fields);

  @override
  ErrorDetail params(Map<String, Object> params) => this(params: params);

  @override
  ErrorDetail requestId(String requestId) => this(requestId: requestId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorDetail call({
    Object? code = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? params = const $CopyWithPlaceholder(),
    Object? requestId = const $CopyWithPlaceholder(),
  }) {
    return ErrorDetail(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as List<FieldProblem>?,
      params: params == const $CopyWithPlaceholder()
          ? _value.params
          // ignore: cast_nullable_to_non_nullable
          : params as Map<String, Object>,
      requestId: requestId == const $CopyWithPlaceholder()
          ? _value.requestId
          // ignore: cast_nullable_to_non_nullable
          : requestId as String,
    );
  }
}

extension $ErrorDetailCopyWith on ErrorDetail {
  /// Returns a callable class that can be used as follows: `instanceOfErrorDetail.copyWith(...)` or like so:`instanceOfErrorDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ErrorDetailCWProxy get copyWith => _$ErrorDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ErrorDetail',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['code', 'fields', 'params', 'requestId'],
    );
    final val = ErrorDetail(
      code: $checkedConvert('code', (v) => v as String),
      fields: $checkedConvert(
        'fields',
        (v) => (v as List<dynamic>?)
            ?.map((e) => FieldProblem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      params: $checkedConvert(
        'params',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      requestId: $checkedConvert('requestId', (v) => v as String),
    );
    return val;
  },
);

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) =>
    <String, dynamic>{
      'code': instance.code,
      'fields': instance.fields?.map((e) => e.toJson()).toList(),
      'params': instance.params,
      'requestId': instance.requestId,
    };
