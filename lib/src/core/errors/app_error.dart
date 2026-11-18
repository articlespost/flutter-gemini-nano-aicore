import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gemini_nano_bridge/src/core/platform/platform_contract.dart';

enum AppErrorCode {
  busy,
  backgroundUseBlocked,
  quotaExceeded,
  notAvailable,
  requestTooLarge,
  notEnoughDiskSpace,
  aicoreIncompatible,
  downloadFailed,
  invalidArgument,
  invalidResponse,
  unknown,
}

@immutable
final class AppError implements Exception {
  const AppError(this.code, {this.retryDelay = Duration.zero, this.cause});

  factory AppError.fromPlatformException(PlatformException exception) {
    final details = exception.details;
    final retryDelayMs = details is Map
        ? details[PlatformErrorDetails.retryDelayMs]
        : null;

    return AppError(
      _codeFromWire(exception.code),
      retryDelay: retryDelayMs is int && retryDelayMs > 0
          ? Duration(milliseconds: retryDelayMs)
          : Duration.zero,
      cause: exception,
    );
  }

  final AppErrorCode code;
  final Duration retryDelay;
  final Object? cause;

  bool get isRetryable => code == AppErrorCode.busy;

  static AppErrorCode _codeFromWire(String code) => switch (code) {
    PlatformErrorCodes.busy => AppErrorCode.busy,
    PlatformErrorCodes.backgroundUseBlocked =>
      AppErrorCode.backgroundUseBlocked,
    PlatformErrorCodes.quotaExceeded => AppErrorCode.quotaExceeded,
    PlatformErrorCodes.notAvailable => AppErrorCode.notAvailable,
    PlatformErrorCodes.requestTooLarge => AppErrorCode.requestTooLarge,
    PlatformErrorCodes.notEnoughDiskSpace => AppErrorCode.notEnoughDiskSpace,
    PlatformErrorCodes.aicoreIncompatible => AppErrorCode.aicoreIncompatible,
    PlatformErrorCodes.downloadFailed => AppErrorCode.downloadFailed,
    PlatformErrorCodes.invalidArgument => AppErrorCode.invalidArgument,
    _ => AppErrorCode.unknown,
  };

  @override
  String toString() => 'AppError(${code.name})';
}
