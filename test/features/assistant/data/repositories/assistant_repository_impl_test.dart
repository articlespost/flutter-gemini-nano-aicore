import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/datasource/gemini_nano_data_source.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/assistant_repository_impl.dart';

void main() {
  final repository = AssistantRepositoryImpl(
    const GeminiNanoDataSource(),
    isSupportedPlatform: false,
  );

  test('fora do Android o modelo é reportado como indisponível', () async {
    final result = await repository.checkAvailability();

    expect(
      (result as Success<ModelAvailability>).value,
      ModelAvailability.unavailable,
    );
  });

  test('fora do Android a geração falha com notAvailable', () async {
    await expectLater(
      repository.generate(const GenerationRequestModel(prompt: 'Oi')),
      emitsError(
        isA<AppError>().having(
          (error) => error.code,
          'code',
          AppErrorCode.notAvailable,
        ),
      ),
    );
  });
}
