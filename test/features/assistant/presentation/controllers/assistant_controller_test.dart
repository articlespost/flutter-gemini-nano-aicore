import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/core/utils/retry_policy.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/services/assistant_service.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/state/assistant_state.dart';

import '../../../../helpers/fake_assistant_repository.dart';

void main() {
  AssistantController buildController(FakeAssistantRepository repository) =>
      AssistantController(
        AssistantService(
          repository,
          retryPolicy: const RetryPolicy(baseDelay: Duration.zero),
        ),
      );

  group('prepare', () {
    test('modelo disponível fica pronto com nome e warmup feito', () async {
      final repository = FakeAssistantRepository();
      final controller = buildController(repository);
      addTearDown(controller.dispose);

      await controller.prepare();

      expect(controller.value.status, AssistantStatus.ready);
      expect(controller.value.modelName, 'nano-test');
      expect(repository.warmupCalls, 1);
    });

    test('aparelho sem Gemini Nano fica unsupported', () async {
      final controller = buildController(
        FakeAssistantRepository(
          availability: const Success(ModelAvailability.unavailable),
        ),
      );
      addTearDown(controller.dispose);

      await controller.prepare();

      expect(controller.value.status, AssistantStatus.unsupported);
    });

    test('falha transitória fica failed com o código do erro', () async {
      final controller = buildController(
        FakeAssistantRepository(
          availability: const Failure(
            AppError(AppErrorCode.aicoreIncompatible),
          ),
        ),
      );
      addTearDown(controller.dispose);

      await controller.prepare();

      expect(controller.value.status, AssistantStatus.failed);
      expect(controller.value.errorCode, AppErrorCode.aicoreIncompatible);
    });

    test('baixa o modelo, acompanha o progresso e termina pronto', () async {
      final repository = FakeAssistantRepository(
        availability: const Success(ModelAvailability.downloadable),
        downloadUpdates: const [
          ModelDownloadStarted(totalBytes: 100),
          ModelDownloadProgress(downloadedBytes: 50),
          ModelDownloadCompleted(),
        ],
      );
      final controller = buildController(repository);
      addTearDown(controller.dispose);
      final progress = <double?>[];
      controller.addListener(
        () => progress.add(controller.value.downloadProgress),
      );

      await controller.prepare();
      await pumpEventQueue();

      expect(progress, containsAllInOrder([0.5, 1.0]));
      expect(controller.value.status, AssistantStatus.ready);
    });

    test('falha no download fica failed com downloadFailed', () async {
      final controller = buildController(
        FakeAssistantRepository(
          availability: const Success(ModelAvailability.downloadable),
          downloadError: const AppError(AppErrorCode.downloadFailed),
        ),
      );
      addTearDown(controller.dispose);

      await controller.prepare();
      await pumpEventQueue();

      expect(controller.value.status, AssistantStatus.failed);
      expect(controller.value.errorCode, AppErrorCode.downloadFailed);
    });
  });

  group('submit', () {
    test('acumula os trechos e volta para ready ao terminar', () async {
      final controller = buildController(
        FakeAssistantRepository(
          generations: [
            () => Stream.fromIterable(['Olá', ', ', 'mundo']),
          ],
        ),
      );
      addTearDown(controller.dispose);
      await controller.prepare();

      controller.submit('Diga oi');
      expect(controller.value.status, AssistantStatus.generating);
      await pumpEventQueue();

      expect(controller.value.response, 'Olá, mundo');
      expect(controller.value.status, AssistantStatus.ready);
    });

    test('erro na geração preserva o texto e mostra o código', () async {
      final controller = buildController(
        FakeAssistantRepository(
          generations: [
            () => chunksThenError([
              'Parcial',
            ], const AppError(AppErrorCode.quotaExceeded)),
          ],
        ),
      );
      addTearDown(controller.dispose);
      await controller.prepare();

      controller.submit('Diga oi');
      await pumpEventQueue();

      expect(controller.value.response, 'Parcial');
      expect(controller.value.status, AssistantStatus.ready);
      expect(controller.value.errorCode, AppErrorCode.quotaExceeded);
    });

    test('ignora envio antes de o modelo estar pronto', () async {
      final repository = FakeAssistantRepository();
      final controller = buildController(repository);
      addTearDown(controller.dispose);

      controller.submit('Diga oi');

      expect(repository.generateCalls, 0);
    });

    test('stop interrompe a geração em andamento', () async {
      final repository = FakeAssistantRepository(
        generations: [
          () => Stream<String>.periodic(
            const Duration(milliseconds: 10),
            (index) => 'trecho $index ',
          ),
        ],
      );
      final controller = buildController(repository);
      addTearDown(controller.dispose);
      await controller.prepare();

      controller.submit('Escreva muito');
      await controller.stop();

      expect(controller.value.status, AssistantStatus.ready);
    });
  });
}
