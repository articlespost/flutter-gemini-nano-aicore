import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/core/utils/retry_policy.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/services/assistant_service.dart';

import '../../../../helpers/fake_assistant_repository.dart';

void main() {
  const busy = AppError(AppErrorCode.busy);
  const noDelayPolicy = RetryPolicy(baseDelay: Duration.zero);

  AssistantService buildService(FakeAssistantRepository repository) =>
      AssistantService(repository, retryPolicy: noDelayPolicy);

  test(
    'tenta de novo quando o AICore responde BUSY antes do primeiro trecho',
    () async {
      final repository = FakeAssistantRepository(
        generations: [
          () => Stream<String>.error(busy),
          () => Stream.fromIterable(['Olá', ' mundo']),
        ],
      );

      final chunks = await buildService(repository)
          .generate(const GenerationRequestModel(prompt: 'Oi'))
          .toList();

      expect(chunks, ['Olá', ' mundo']);
      expect(repository.generateCalls, 2);
    },
  );

  test('não repete a geração depois que um trecho já foi entregue', () async {
    final repository = FakeAssistantRepository(
      generations: [
        () => chunksThenError(['Olá'], busy),
      ],
    );

    final stream = buildService(repository)
        .generate(const GenerationRequestModel(prompt: 'Oi'));

    await expectLater(stream, emitsInOrder(['Olá', emitsError(busy)]));
    expect(repository.generateCalls, 1);
  });

  test('não tenta de novo quando a cota foi estourada', () async {
    const quota = AppError(AppErrorCode.quotaExceeded);
    final repository = FakeAssistantRepository(
      generations: [() => Stream<String>.error(quota)],
    );

    await expectLater(
      buildService(repository)
          .generate(const GenerationRequestModel(prompt: 'Oi')),
      emitsError(quota),
    );
    expect(repository.generateCalls, 1);
  });

  test('desiste depois do limite de tentativas', () async {
    final repository = FakeAssistantRepository(
      generations: List.generate(
        4,
        (_) =>
            () => Stream<String>.error(busy),
      ),
    );

    await expectLater(
      buildService(repository)
          .generate(const GenerationRequestModel(prompt: 'Oi')),
      emitsError(busy),
    );
    expect(repository.generateCalls, 4);
  });

  test('remove espaços nas pontas do prompt antes de enviar', () async {
    final repository = FakeAssistantRepository(
      generations: [() => const Stream<String>.empty()],
    );

    await buildService(repository)
        .generate(const GenerationRequestModel(prompt: '  Oi  '))
        .drain<void>();

    expect(repository.lastRequest?.prompt, 'Oi');
  });

  test('rejeita prompt vazio ou acima do limite sem chamar o modelo', () async {
    final repository = FakeAssistantRepository();
    final service = buildService(repository);

    for (final prompt in [
      '   ',
      'a' * (AssistantService.maxPromptLength + 1),
    ]) {
      await expectLater(
        service.generate(GenerationRequestModel(prompt: prompt)),
        emitsError(
          isA<AppError>().having(
            (error) => error.code,
            'code',
            AppErrorCode.invalidArgument,
          ),
        ),
      );
    }
    expect(repository.generateCalls, 0);
  });
}
