import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/router/app_routes.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/screens/assistant_screen.dart';

abstract final class RouteGenerator {
  static Route<void> pageFor(RouteSettings settings) => switch (settings.name) {
    AppRoutes.assistant => _build(settings, const AssistantScreen()),
    _ => _build(
      const RouteSettings(name: AppRoutes.initial),
      const AssistantScreen(),
    ),
  };

  static List<Route<void>> initialRoutes(String initialRouteName) => [
    pageFor(RouteSettings(name: initialRouteName)),
  ];

  static Route<void> _build(RouteSettings settings, Widget page) =>
      MaterialPageRoute<void>(settings: settings, builder: (_) => page);
}
