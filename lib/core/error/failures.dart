import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.validation({
    required String message,
    Map<String, List<String>>? errors,
  }) = ValidationFailure;

  const factory Failure.unauthorized({
    required String message,
  }) = UnauthorizedFailure;

  const factory Failure.forbidden({
    required String message,
  }) = ForbiddenFailure;

  const factory Failure.notFound({
    required String message,
  }) = NotFoundFailure;

  const factory Failure.timeout({
    required String message,
  }) = TimeoutFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}

extension FailureX on Failure {
  String get message => when(
        server: (message, _) => message,
        network: (message) => message,
        cache: (message) => message,
        validation: (message, _) => message,
        unauthorized: (message) => message,
        forbidden: (message) => message,
        notFound: (message) => message,
        timeout: (message) => message,
        unknown: (message) => message,
      );
}

