import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';

abstract class IAssistantRepository {
  Future<Result<ModelAvailability>> checkAvailability();

  Future<Result<void>> warmup();

  Future<Result<String>> fetchModelName();

  Stream<ModelDownloadUpdate> downloadModel();

  Stream<String> generate(GenerationRequestModel request);
}
