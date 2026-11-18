import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_spacing.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/state/assistant_state.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/error_banner.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/model_header.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/prompt_composer.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/prompt_suggestions.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/widgets/response_view.dart';

class AssistantConversation extends StatelessWidget {
  const AssistantConversation({
    super.key,
    required this.state,
    required this.promptController,
    required this.onSubmit,
    required this.onStop,
    required this.onSuggestionSelected,
  });

  final AssistantState state;
  final TextEditingController promptController;
  final VoidCallback onSubmit;
  final VoidCallback onStop;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final errorCode = state.errorCode;
    final showSuggestions = state.response.isEmpty && !state.isGenerating;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelHeader(modelName: state.modelName),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ResponseView(
                  response: state.response,
                  isGenerating: state.isGenerating,
                ),
              ),
              if (errorCode != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorBanner(
                  message: AssistantScreenStrings.errorMessage(errorCode),
                ),
              ],
              if (showSuggestions) ...[
                const SizedBox(height: AppSpacing.md),
                PromptSuggestions(
                  suggestions: AssistantScreenStrings.suggestions,
                  onSelected: onSuggestionSelected,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              PromptComposer(
                controller: promptController,
                isGenerating: state.isGenerating,
                onSubmit: onSubmit,
                onStop: onStop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
