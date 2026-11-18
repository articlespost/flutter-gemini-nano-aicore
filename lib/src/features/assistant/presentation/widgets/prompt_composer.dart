import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_spacing.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/services/assistant_service.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';

class PromptComposer extends StatelessWidget {
  const PromptComposer({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSubmit,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !isGenerating,
            minLines: 1,
            maxLines: 5,
            maxLength: AssistantService.maxPromptLength,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AssistantScreenStrings.promptHint,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isGenerating)
          IconButton.filledTonal(
            onPressed: onStop,
            tooltip: AssistantScreenStrings.stop,
            icon: const Icon(Icons.stop_rounded),
          )
        else
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => IconButton.filled(
              onPressed: value.text.trim().isEmpty ? null : onSubmit,
              tooltip: AssistantScreenStrings.send,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ),
      ],
    );
  }
}
