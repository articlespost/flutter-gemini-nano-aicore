import 'package:gemini_nano_bridge/src/core/errors/app_error.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final error) => failure(error),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final error) => Failure(error),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;
}
