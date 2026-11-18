import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gemini_nano_bridge/src/core/errors/app_error.dart';
import 'package:gemini_nano_bridge/src/core/errors/result.dart';

abstract final class ResultUtils {
  static Future<Result<T>> safeCall<T>(Future<T> Function() call) async {
    try {
      return Success(await call());
    } on Exception catch (exception) {
      return Failure(normalize(exception));
    }
  }

  static Stream<T> guardStream<T>(Stream<T> stream) => stream.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) => sink.addError(
        error is Exception ? normalize(error) : error,
        stackTrace,
      ),
    ),
  );

  static AppError normalize(Exception exception) => switch (exception) {
    final AppError error => error,
    final PlatformException error => AppError.fromPlatformException(error),
    MissingPluginException() => AppError(
      AppErrorCode.notAvailable,
      cause: exception,
    ),
    FormatException() => AppError(
      AppErrorCode.invalidResponse,
      cause: exception,
    ),
    _ => AppError(AppErrorCode.unknown, cause: exception),
  };
}
