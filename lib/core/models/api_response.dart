import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required Meta meta,
    required T data,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@freezed
class Meta with _$Meta {
  const factory Meta({
    required int code,
    required String message,
  }) = _Meta;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

