import 'package:flutter/services.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/core/platform/platform_contract.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/download_event_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/model_status_model.dart';

class GeminiNanoDataSource {
  const GeminiNanoDataSource({
    this._methodChannel = const MethodChannel(PlatformChannels.methods),
    this._downloadChannel = const EventChannel(PlatformChannels.download),
    this._generationChannel = const EventChannel(PlatformChannels.generation),
  });

  final MethodChannel _methodChannel;
  final EventChannel _downloadChannel;
  final EventChannel _generationChannel;

  Future<Result<ModelStatusModel>> checkStatus() => ResultUtils.safeCall(
    () async => ModelStatusModel.fromWire(
      await _methodChannel.invokeMethod<Object?>(PlatformMethods.checkStatus),
    ),
  );

  Future<Result<void>> warmup() => ResultUtils.safeCall<void>(
    () => _methodChannel.invokeMethod<void>(PlatformMethods.warmup),
  );

  Future<Result<String>> fetchBaseModelName() => ResultUtils.safeCall(() async {
    final raw = await _methodChannel.invokeMethod<Object?>(
      PlatformMethods.baseModelName,
    );
    return raw is String && raw.isNotEmpty
        ? raw
        : throw FormatException('Unexpected base model name', raw);
  });

  Stream<DownloadEventModel> download() => ResultUtils.guardStream(
    _downloadChannel.receiveBroadcastStream().map(DownloadEventModel.fromMap),
  );

  Stream<String> generate(GenerationRequestModel request) =>
      ResultUtils.guardStream(
        _generationChannel
            .receiveBroadcastStream(request.toMap())
            .map(_toChunk),
      );

  static String _toChunk(Object? raw) => raw is String
      ? raw
      : throw const FormatException('Unexpected generation chunk');
}
