import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/core/utils/retry_policy.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/i_assistant_repository.dart';

class AssistantService {
  const AssistantService(
    this._repository, {
    this._retryPolicy = const RetryPolicy(),
  });

  static const int maxPromptLength = 4000;

  final IAssistantRepository _repository;
  final RetryPolicy _retryPolicy;

  Future<Result<ModelAvailability>> checkAvailability() =>
      _repository.checkAvailability();

  Future<Result<void>> warmup() => _repository.warmup();

  Future<Result<String>> fetchModelName() => _repository.fetchModelName();

  Stream<ModelDownloadUpdate> downloadModel() => _repository.downloadModel();

  Stream<String> generate(GenerationRequestModel request) async* {
    final prompt = request.prompt.trim();
    if (prompt.isEmpty || prompt.length > maxPromptLength) {
      throw const AppError(AppErrorCode.invalidArgument);
    }
    final sanitizedRequest = request.copyWith(prompt: prompt);

    for (var attempt = 0; ; attempt++) {
      var hasEmitted = false;
      try {
        await for (final chunk in _repository.generate(sanitizedRequest)) {
          hasEmitted = true;
          yield chunk;
        }
        return;
      } on AppError catch (error) {
        final delay = _retryPolicy.delayFor(
          attempt,
          suggested: error.retryDelay,
        );
        if (hasEmitted || !error.isRetryable || delay == null) rethrow;
        await Future<void>.delayed(delay);
      }
    }
  }
}
