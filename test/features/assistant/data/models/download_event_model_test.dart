import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/download_event_model.dart';

void main() {
  test('converte started em ModelDownloadStarted', () {
    final update = DownloadEventModel.fromMap({
      'type': 'started',
      'bytes': 2048,
    }).toEntity();

    expect(
      update,
      isA<ModelDownloadStarted>().having(
        (event) => event.totalBytes,
        'totalBytes',
        2048,
      ),
    );
  });

  test('converte progress em ModelDownloadProgress', () {
    final update = DownloadEventModel.fromMap({
      'type': 'progress',
      'bytes': 512,
    }).toEntity();

    expect(
      update,
      isA<ModelDownloadProgress>().having(
        (event) => event.downloadedBytes,
        'downloadedBytes',
        512,
      ),
    );
  });

  test('converte completed sem bytes', () {
    final update = DownloadEventModel.fromMap({
      'type': 'completed',
      'bytes': null,
    }).toEntity();

    expect(update, isA<ModelDownloadCompleted>());
  });

  test('rejeita tipo desconhecido com FormatException', () {
    expect(
      () => DownloadEventModel.fromMap({'type': 'paused'}),
      throwsFormatException,
    );
  });

  test('rejeita payload que não é Map', () {
    expect(() => DownloadEventModel.fromMap('started'), throwsFormatException);
  });
}
