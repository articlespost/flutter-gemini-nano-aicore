import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';

abstract final class AssistantScreenStrings {
  static String get title => 'Gemini Nano on-device';
  static String get checking => 'Verificando o modelo no aparelho...';
  static String get downloadingTitle => 'Baixando o Gemini Nano';
  static String get downloadingMessage =>
      'O download é feito uma única vez pelo Android AICore e fica disponível offline.';
  static String get unsupportedTitle => 'IA on-device indisponível';
  static String get unsupportedMessage =>
      'Este aparelho não oferece o Gemini Nano pelo Android AICore.';
  static String get failedTitle => 'Não foi possível preparar o modelo';
  static String get retry => 'Tentar novamente';
  static String get promptHint => 'Escreva o que deseja ao Gemini Nano';
  static String get send => 'Enviar';
  static String get stop => 'Parar';
  static String get responsePlaceholder =>
      'A resposta aparece aqui, gerada no próprio aparelho, sem internet.';
  static String get onDeviceBadge => 'On-device';
  static String get unknownModel => 'Gemini Nano';

  static String downloadedMegabytes(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  static List<String> get suggestions => const [
    'Resuma em três tópicos: reuniões curtas e com pauta definida aumentam a produtividade do time.',
    'Reescreva de forma formal: preciso adiar a entrega para sexta.',
    'Sugira três respostas curtas para: vamos marcar o café amanhã?',
  ];

  static String errorMessage(AppErrorCode? code) => switch (code) {
    AppErrorCode.busy =>
      'O modelo está ocupado no momento. Tente novamente em instantes.',
    AppErrorCode.backgroundUseBlocked =>
      'A geração foi interrompida porque o app saiu do primeiro plano.',
    AppErrorCode.quotaExceeded => 'A cota de uso de IA deste app no aparelho foi atingida. Tente mais tarde.',
    AppErrorCode.notAvailable =>
      'O Gemini Nano não está disponível neste aparelho.',
    AppErrorCode.requestTooLarge => 'O texto é grande demais para o modelo on-device. Reduza e tente de novo.',
    AppErrorCode.notEnoughDiskSpace =>
      'Espaço insuficiente no aparelho para baixar o modelo.',
    AppErrorCode.aicoreIncompatible =>
      'Atualize o Android AICore pela Play Store e tente novamente.',
    AppErrorCode.downloadFailed =>
      'O download do modelo falhou. Verifique a conexão e tente novamente.',
    AppErrorCode.invalidArgument => 'Escreva um texto de até 4000 caracteres.',
    AppErrorCode.invalidResponse ||
    AppErrorCode.unknown ||
    null => 'Algo deu errado. Tente novamente.',
  };
}
