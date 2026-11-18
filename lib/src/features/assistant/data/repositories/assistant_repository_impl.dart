import 'package:flutter/foundation.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/datasource/gemini_nano_data_source.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/i_assistant_repository.dart';

class AssistantRepositoryImpl implements IAssistantRepository {
  AssistantRepositoryImpl(this._dataSource, {bool? isSupportedPlatform})
    : _isSupportedPlatform =
          isSupportedPlatform ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final GeminiNanoDataSource _dataSource;
  final bool _isSupportedPlatform;

  static const AppError _unsupportedPlatform = AppError(
    AppErrorCode.notAvailable,
  );

  @override
  Future<Result<ModelAvailability>> checkAvailability() async {
    if (!_isSupportedPlatform) {
      return const Success(ModelAvailability.unavailable);
    }
    final result = await _dataSource.checkStatus();
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Result<void>> warmup() async {
    if (!_isSupportedPlatform) return const Failure(_unsupportedPlatform);
    return _dataSource.warmup();
  }

  @override
  Future<Result<String>> fetchModelName() async {
    if (!_isSupportedPlatform) return const Failure(_unsupportedPlatform);
    return _dataSource.fetchBaseModelName();
  }

  @override
  Stream<ModelDownloadUpdate> downloadModel() {
    if (!_isSupportedPlatform) return Stream.error(_unsupportedPlatform);
    return _dataSource.download().map((model) => model.toEntity());
  }

  @override
  Stream<String> generate(GenerationRequestModel request) {
    if (!_isSupportedPlatform) return Stream.error(_unsupportedPlatform);
    return _dataSource.generate(request);
  }
}
