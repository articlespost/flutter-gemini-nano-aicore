class GenerationRequestModel {
  const GenerationRequestModel({
    required this.prompt,
    this.temperature = 0.3,
    this.topK = 16,
    this.maxOutputTokens = 512,
  });

  final String prompt;
  final double temperature;
  final int topK;
  final int maxOutputTokens;

  GenerationRequestModel copyWith({String? prompt}) => GenerationRequestModel(
    prompt: prompt ?? this.prompt,
    temperature: temperature,
    topK: topK,
    maxOutputTokens: maxOutputTokens,
  );

  Map<String, Object> toMap() => {
    'prompt': prompt,
    'temperature': temperature,
    'topK': topK,
    'maxOutputTokens': maxOutputTokens,
  };
}
