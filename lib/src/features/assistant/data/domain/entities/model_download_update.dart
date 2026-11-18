sealed class ModelDownloadUpdate {
  const ModelDownloadUpdate();
}

final class ModelDownloadStarted extends ModelDownloadUpdate {
  const ModelDownloadStarted({required this.totalBytes});

  final int totalBytes;
}

final class ModelDownloadProgress extends ModelDownloadUpdate {
  const ModelDownloadProgress({required this.downloadedBytes});

  final int downloadedBytes;
}

final class ModelDownloadCompleted extends ModelDownloadUpdate {
  const ModelDownloadCompleted();
}
