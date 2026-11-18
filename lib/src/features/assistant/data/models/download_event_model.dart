import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';

enum DownloadEventType { started, progress, completed }

class DownloadEventModel {
  const DownloadEventModel({required this.type, this.bytes});

  factory DownloadEventModel.fromMap(Object? raw) {
    if (raw is! Map) {
      throw FormatException('Unexpected download event', raw);
    }
    final type = switch (raw['type']) {
      'started' => DownloadEventType.started,
      'progress' => DownloadEventType.progress,
      'completed' => DownloadEventType.completed,
      final other => throw FormatException('Unknown download event', other),
    };
    final bytes = raw['bytes'];
    if (bytes != null && bytes is! int) {
      throw FormatException('Unexpected download bytes', bytes);
    }
    return DownloadEventModel(type: type, bytes: bytes as int?);
  }

  final DownloadEventType type;
  final int? bytes;

  ModelDownloadUpdate toEntity() => switch (type) {
    DownloadEventType.started => ModelDownloadStarted(totalBytes: bytes ?? 0),
    DownloadEventType.progress => ModelDownloadProgress(
      downloadedBytes: bytes ?? 0,
    ),
    DownloadEventType.completed => const ModelDownloadCompleted(),
  };
}
