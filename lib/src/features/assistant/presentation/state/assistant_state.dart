import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';

enum AssistantStatus {
  checking,
  downloading,
  ready,
  generating,
  unsupported,
  failed,
}

@immutable
class AssistantState {
  const AssistantState({
    this.status = AssistantStatus.checking,
    this.modelName,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.response = '',
    this.errorCode,
  });

  final AssistantStatus status;
  final String? modelName;
  final int totalBytes;
  final int downloadedBytes;
  final String response;
  final AppErrorCode? errorCode;

  bool get isGenerating => status == AssistantStatus.generating;

  bool get canSubmit => status == AssistantStatus.ready;

  double? get downloadProgress =>
      totalBytes > 0 ? math.min(1, downloadedBytes / totalBytes) : null;

  AssistantState copyWith({
    AssistantStatus? status,
    String? modelName,
    int? totalBytes,
    int? downloadedBytes,
    String? response,
    AppErrorCode? errorCode,
    bool clearError = false,
  }) => AssistantState(
    status: status ?? this.status,
    modelName: modelName ?? this.modelName,
    totalBytes: totalBytes ?? this.totalBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    response: response ?? this.response,
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantState &&
          status == other.status &&
          modelName == other.modelName &&
          totalBytes == other.totalBytes &&
          downloadedBytes == other.downloadedBytes &&
          response == other.response &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(
    status,
    modelName,
    totalBytes,
    downloadedBytes,
    response,
    errorCode,
  );
}
