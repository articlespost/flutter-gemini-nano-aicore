import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/core/platform/platform_contract.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/datasource/gemini_nano_data_source.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/download_event_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/model_status_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(PlatformChannels.methods);
  const downloadChannel = EventChannel(PlatformChannels.download);
  const generationChannel = EventChannel(PlatformChannels.generation);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const dataSource = GeminiNanoDataSource();

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(methodChannel, null)
      ..setMockStreamHandler(downloadChannel, null)
      ..setMockStreamHandler(generationChannel, null);
  });

  group('checkStatus', () {
    test('lê o status do canal nativo', () async {
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        expect(call.method, PlatformMethods.checkStatus);
        return 'downloadable';
      });

      final result = await dataSource.checkStatus();

      expect(
        (result as Success<ModelStatusModel>).value.toEntity(),
        ModelAvailability.downloadable,
      );
    });

    test('status fora do contrato vira invalidResponse', () async {
      messenger.setMockMethodCallHandler(methodChannel, (_) async => 42);

      final result = await dataSource.checkStatus();

      expect(
        (result as Failure<ModelStatusModel>).error.code,
        AppErrorCode.invalidResponse,
      );
    });
  });

  test('fetchBaseModelName rejeita nome vazio', () async {
    messenger.setMockMethodCallHandler(methodChannel, (_) async => '');

    final result = await dataSource.fetchBaseModelName();

    expect(
      (result as Failure<String>).error.code,
      AppErrorCode.invalidResponse,
    );
  });

  test('download traduz os eventos do EventChannel', () async {
    messenger.setMockStreamHandler(
      downloadChannel,
      MockStreamHandler.inline(
        onListen: (_, events) {
          events
            ..success({'type': 'started', 'bytes': 100})
            ..success({'type': 'progress', 'bytes': 40})
            ..success({'type': 'completed', 'bytes': null})
            ..endOfStream();
        },
      ),
    );

    final types = await dataSource
        .download()
        .map((event) => event.type)
        .toList();

    expect(types, [
      DownloadEventType.started,
      DownloadEventType.progress,
      DownloadEventType.completed,
    ]);
  });

  group('generate', () {
    test('envia os parâmetros e recebe os trechos em ordem', () async {
      Object? sentArguments;
      messenger.setMockStreamHandler(
        generationChannel,
        MockStreamHandler.inline(
          onListen: (arguments, events) {
            sentArguments = arguments;
            events
              ..success('Olá')
              ..success(', mundo')
              ..endOfStream();
          },
        ),
      );

      final chunks = await dataSource
          .generate(const GenerationRequestModel(prompt: 'Diga oi'))
          .toList();

      expect(chunks, ['Olá', ', mundo']);
      expect(sentArguments, {
        'prompt': 'Diga oi',
        'temperature': 0.3,
        'topK': 16,
        'maxOutputTokens': 512,
      });
    });

    test('erro nativo chega como AppError com retryDelay', () async {
      messenger.setMockStreamHandler(
        generationChannel,
        MockStreamHandler.inline(
          onListen: (_, events) =>
              events.error(code: 'BUSY', details: {'retryDelayMs': 300}),
        ),
      );

      await expectLater(
        dataSource.generate(const GenerationRequestModel(prompt: 'Oi')),
        emitsError(
          isA<AppError>()
              .having((error) => error.code, 'code', AppErrorCode.busy)
              .having(
                (error) => error.retryDelay,
                'retryDelay',
                const Duration(milliseconds: 300),
              ),
        ),
      );
    });
  });
}
