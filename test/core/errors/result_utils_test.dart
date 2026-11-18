import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';

void main() {
  group('ResultUtils.safeCall', () {
    test('devolve Success com o valor da chamada', () async {
      final result = await ResultUtils.safeCall(() async => 42);

      expect(result, isA<Success<int>>());
      expect((result as Success<int>).value, 42);
    });

    test('converte BUSY em AppErrorCode.busy com retryDelay', () async {
      final result = await ResultUtils.safeCall<int>(
        () => throw PlatformException(
          code: 'BUSY',
          details: {'retryDelayMs': 1200},
        ),
      );

      final error = (result as Failure<int>).error;
      expect(error.code, AppErrorCode.busy);
      expect(error.retryDelay, const Duration(milliseconds: 1200));
      expect(error.isRetryable, isTrue);
    });

    test('converte MissingPluginException em notAvailable', () async {
      final result = await ResultUtils.safeCall<int>(
        () => throw MissingPluginException(),
      );

      expect((result as Failure<int>).error.code, AppErrorCode.notAvailable);
    });

    test('converte FormatException em invalidResponse', () async {
      final result = await ResultUtils.safeCall<int>(
        () => throw const FormatException('payload inesperado'),
      );

      expect((result as Failure<int>).error.code, AppErrorCode.invalidResponse);
    });

    test('mapeia código desconhecido do nativo para unknown', () async {
      final result = await ResultUtils.safeCall<int>(
        () => throw PlatformException(code: 'GENAI_999'),
      );

      expect((result as Failure<int>).error.code, AppErrorCode.unknown);
    });

    test('não captura Error de programação', () async {
      await expectLater(
        ResultUtils.safeCall<int>(() => throw StateError('bug')),
        throwsStateError,
      );
    });
  });

  group('ResultUtils.guardStream', () {
    test('converte erro de plataforma no stream em AppError', () async {
      final stream = ResultUtils.guardStream(
        Stream<String>.error(PlatformException(code: 'QUOTA_EXCEEDED')),
      );

      await expectLater(
        stream,
        emitsError(
          isA<AppError>().having(
            (error) => error.code,
            'code',
            AppErrorCode.quotaExceeded,
          ),
        ),
      );
    });
  });

  test('AppError.toString não expõe a causa original', () {
    final error = AppError(
      AppErrorCode.unknown,
      cause: PlatformException(code: 'X', message: 'detalhe interno'),
    );

    expect(error.toString(), isNot(contains('detalhe interno')));
  });
}
