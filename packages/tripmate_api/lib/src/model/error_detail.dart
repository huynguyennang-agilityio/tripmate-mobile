//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tripmate_api/src/model/field_problem.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_detail.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ErrorDetail {
  /// Returns a new [ErrorDetail] instance.
  ErrorDetail({
    required this.code,

    required this.fields,

    required this.params,

    required this.requestId,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'fields', required: true, includeIfNull: true)
  final List<FieldProblem>? fields;

  @JsonKey(name: r'params', required: true, includeIfNull: false)
  final Map<String, Object> params;

  @JsonKey(name: r'requestId', required: true, includeIfNull: false)
  final String requestId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorDetail &&
          other.code == code &&
          other.fields == fields &&
          other.params == params &&
          other.requestId == requestId;

  @override
  int get hashCode =>
      code.hashCode +
      (fields == null ? 0 : fields.hashCode) +
      params.hashCode +
      requestId.hashCode;

  factory ErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
