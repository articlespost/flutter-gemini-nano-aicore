import 'package:flutter/widgets.dart';
import 'package:gemini_nano_bridge/src/app.dart';
import 'package:gemini_nano_bridge/src/core/di/app_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GeminiNanoApp(container: AppContainer()));
}
