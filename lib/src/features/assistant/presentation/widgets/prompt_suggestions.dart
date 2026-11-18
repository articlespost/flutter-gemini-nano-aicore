import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_spacing.dart';

class PromptSuggestions extends StatelessWidget {
  const PromptSuggestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: ActionChip(
              label: Text(suggestion, overflow: TextOverflow.ellipsis),
              onPressed: () => onSelected(suggestion),
            ),
          );
        },
      ),
    );
  }
}
