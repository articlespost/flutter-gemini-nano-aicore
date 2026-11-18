import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_spacing.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.strings.dart';

class ModelHeader extends StatelessWidget {
  const ModelHeader({super.key, required this.modelName});

  final String? modelName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.memory_rounded, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            modelName ?? AssistantScreenStrings.unknownModel,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Chip(
          avatar: const Icon(Icons.wifi_off_rounded, size: 18),
          label: Text(AssistantScreenStrings.onDeviceBadge),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
