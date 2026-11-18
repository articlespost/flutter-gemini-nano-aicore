import 'package:flutter/material.dart';
import 'package:gemini_nano_bridge/src/core/di/app_container.dart';
import 'package:gemini_nano_bridge/src/core/di/app_scope.dart';
import 'package:gemini_nano_bridge/src/core/router/app_routes.dart';
import 'package:gemini_nano_bridge/src/core/router/route_generator.dart';
import 'package:gemini_nano_bridge/src/core/theme/app_theme.dart';

class GeminiNanoApp extends StatelessWidget {
  const GeminiNanoApp({super.key, required this.container});

  final AppContainer container;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      container: container,
      child: MaterialApp(
        title: 'Gemini Nano Bridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: RouteGenerator.pageFor,
        onGenerateInitialRoutes: RouteGenerator.initialRoutes,
      ),
    );
  }
}
