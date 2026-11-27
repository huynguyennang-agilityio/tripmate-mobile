//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'field_problem.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FieldProblem {
  /// Returns a new [FieldProblem] instance.
  FieldProblem({required this.code, required this.field});

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'field', required: true, includeIfNull: false)
  final String field;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldProblem && other.code == code && other.field == field;

  @override
  int get hashCode => code.hashCode + field.hashCode;

  factory FieldProblem.fromJson(Map<String, dynamic> json) =>
      _$FieldProblemFromJson(json);

  Map<String, dynamic> toJson() => _$FieldProblemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
