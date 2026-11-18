abstract final class PlatformChannels {
  static const String _prefix = 'com.articlespost.gemini_nano';

  static const String methods = '$_prefix/methods';
  static const String download = '$_prefix/download';
  static const String generation = '$_prefix/generation';
}

abstract final class PlatformMethods {
  static const String checkStatus = 'checkStatus';
  static const String warmup = 'warmup';
  static const String baseModelName = 'baseModelName';
}

abstract final class PlatformErrorCodes {
  static const String busy = 'BUSY';
  static const String backgroundUseBlocked = 'BACKGROUND_USE_BLOCKED';
  static const String quotaExceeded = 'QUOTA_EXCEEDED';
  static const String notAvailable = 'NOT_AVAILABLE';
  static const String requestTooLarge = 'REQUEST_TOO_LARGE';
  static const String notEnoughDiskSpace = 'NOT_ENOUGH_DISK_SPACE';
  static const String aicoreIncompatible = 'AICORE_INCOMPATIBLE';
  static const String downloadFailed = 'DOWNLOAD_FAILED';
  static const String invalidArgument = 'INVALID_ARGUMENT';
}

abstract final class PlatformErrorDetails {
  static const String retryDelayMs = 'retryDelayMs';
}
