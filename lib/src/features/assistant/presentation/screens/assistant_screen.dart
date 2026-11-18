import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/di/app_scope.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/state/assistant_state.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/assistant_conversation.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/status_message.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  static const String routeName = '/assistant';

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  late final AppLifecycleListener _lifecycleListener;
  AssistantController? _controller;

  AssistantController get _assistant => _controller!;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onHide: _onAppHidden);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final controller = AppScope.of(context).createAssistantController();
    _controller = controller;
    unawaited(controller.prepare());
  }

  void _onAppHidden() => unawaited(_controller?.stop());

  void _submit() {
    final prompt = _promptController.text;
    if (prompt.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _assistant.submit(prompt);
  }

  void _stop() => unawaited(_assistant.stop());

  void _retry() => unawaited(_assistant.prepare());

  void _useSuggestion(String suggestion) {
    _promptController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _promptController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AssistantScreenStrings.title)),
      body: SafeArea(
        child: ValueListenableBuilder<AssistantState>(
          valueListenable: _assistant,
          builder: (context, state, _) => switch (state.status) {
            AssistantStatus.checking => StatusMessage(
              icon: Icons.memory_rounded,
              title: AssistantScreenStrings.checking,
              showProgress: true,
            ),
            AssistantStatus.downloading => StatusMessage(
              icon: Icons.downloading_rounded,
              title: AssistantScreenStrings.downloadingTitle,
              message:
                  '${AssistantScreenStrings.downloadingMessage}\n'
                  '${AssistantScreenStrings.downloadedMegabytes(state.downloadedBytes)}',
              progress: state.downloadProgress,
              showProgress: true,
            ),
            AssistantStatus.unsupported => StatusMessage(
              icon: Icons.phonelink_erase_rounded,
              title: AssistantScreenStrings.unsupportedTitle,
              message: AssistantScreenStrings.unsupportedMessage,
            ),
            AssistantStatus.failed => StatusMessage(
              icon: Icons.error_outline_rounded,
              title: AssistantScreenStrings.failedTitle,
              message: AssistantScreenStrings.errorMessage(state.errorCode),
              actionLabel: AssistantScreenStrings.retry,
              onAction: _retry,
            ),
            AssistantStatus.ready ||
            AssistantStatus.generating => AssistantConversation(
              state: state,
              promptController: _promptController,
              onSubmit: _submit,
              onStop: _stop,
              onSuggestionSelected: _useSuggestion,
            ),
          },
        ),
      ),
    );
  }
}
