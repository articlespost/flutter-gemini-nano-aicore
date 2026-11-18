import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/app.dart';
import 'package:gemini_nano_bridge/src/core/di/app_container.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';

import '../../../../helpers/fake_assistant_repository.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    FakeAssistantRepository repository,
  ) async {
    await tester.pumpWidget(
      GeminiNanoApp(container: AppContainer(assistantRepository: repository)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra aviso quando o aparelho não tem Gemini Nano', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAssistantRepository(
        availability: const Success(ModelAvailability.unavailable),
      ),
    );

    expect(find.text(AssistantScreenStrings.unsupportedTitle), findsOneWidget);
  });

  testWidgets('abre como rota única, sem botão de voltar', (tester) async {
    await pumpApp(tester, FakeAssistantRepository());

    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(AssistantScreen), findsOneWidget);
  });

  testWidgets('falha ao preparar oferece tentar novamente', (tester) async {
    final repository = FakeAssistantRepository(
      availability: const Failure(AppError(AppErrorCode.aicoreIncompatible)),
    );
    await pumpApp(tester, repository);

    expect(find.text(AssistantScreenStrings.failedTitle), findsOneWidget);

    repository.availability = const Success(ModelAvailability.available);
    await tester.tap(find.text(AssistantScreenStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text('nano-test'), findsOneWidget);
  });

  testWidgets('envia o prompt e exibe a resposta gerada em streaming', (
    tester,
  ) async {
    final repository = FakeAssistantRepository(
      generations: [
        () => Stream.fromIterable(['Olá', ', ', 'mundo']),
      ],
    );
    await pumpApp(tester, repository);

    await tester.enterText(find.byType(TextField), 'Diga oi');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Olá, mundo'), findsOneWidget);
    expect(repository.lastRequest?.prompt, 'Diga oi');
  });

  testWidgets('botão de enviar fica desabilitado sem texto', (tester) async {
    await pumpApp(tester, FakeAssistantRepository());

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded),
    );

    expect(button.onPressed, isNull);
  });
}
