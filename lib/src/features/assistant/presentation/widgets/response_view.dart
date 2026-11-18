import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_spacing.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';

class ResponseView extends StatelessWidget {
  const ResponseView({
    super.key,
    required this.response,
    required this.isGenerating,
  });

  final String response;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 2,
            child: isGenerating ? const LinearProgressIndicator() : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: response.isEmpty
                    ? Text(
                        AssistantScreenStrings.responsePlaceholder,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : SelectableText(
                        response,
                        style: theme.textTheme.bodyLarge,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
