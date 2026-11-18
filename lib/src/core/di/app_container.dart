import 'package:gemini_nano_bridge/src/features/assistant/data/datasource/gemini_nano_data_source.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/repositories/i_assistant_repository.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/services/assistant_service.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/controllers/assistant_controller.dart';

class AppContainer {
  AppContainer({IAssistantRepository? assistantRepository})
    : _assistantRepository =
          assistantRepository ??
          AssistantRepositoryImpl(const GeminiNanoDataSource());

  final IAssistantRepository _assistantRepository;

  late final AssistantService _assistantService = AssistantService(
    _assistantRepository,
  );

  AssistantController createAssistantController() =>
      AssistantController(_assistantService);
}
