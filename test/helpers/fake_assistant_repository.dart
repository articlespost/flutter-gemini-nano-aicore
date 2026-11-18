import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/i_assistant_repository.dart';

class FakeAssistantRepository implements IAssistantRepository {
  FakeAssistantRepository({
    this.availability = const Success(ModelAvailability.available),
    this.modelName = const Success('nano-test'),
    this.downloadUpdates = const [],
    this.downloadError,
    List<Stream<String> Function()>? generations,
  }) : _generations = generations ?? [];

  Result<ModelAvailability> availability;
  Result<String> modelName;
  List<ModelDownloadUpdate> downloadUpdates;
  AppError? downloadError;
  final List<Stream<String> Function()> _generations;

  int warmupCalls = 0;
  int generateCalls = 0;
  GenerationRequestModel? lastRequest;

  @override
  Future<Result<ModelAvailability>> checkAvailability() async => availability;

  @override
  Future<Result<void>> warmup() async {
    warmupCalls++;
    return const Success(null);
  }

  @override
  Future<Result<String>> fetchModelName() async => modelName;

  @override
  Stream<ModelDownloadUpdate> downloadModel() async* {
    for (final update in downloadUpdates) {
      yield update;
    }
    final error = downloadError;
    if (error != null) throw error;
    availability = const Success(ModelAvailability.available);
  }

  @override
  Stream<String> generate(GenerationRequestModel request) {
    generateCalls++;
    lastRequest = request;
    return _generations.removeAt(0)();
  }
}

Stream<String> chunksThenError(List<String> chunks, AppError error) async* {
  for (final chunk in chunks) {
    yield chunk;
  }
  throw error;
}
