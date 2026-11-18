import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';

class ModelStatusModel {
  const ModelStatusModel(this.availability);

  factory ModelStatusModel.fromWire(Object? raw) =>
      ModelStatusModel(switch (raw) {
        'available' => ModelAvailability.available,
        'downloadable' => ModelAvailability.downloadable,
        'downloading' => ModelAvailability.downloading,
        'unavailable' => ModelAvailability.unavailable,
        _ => throw FormatException('Unexpected model status', raw),
      });

  final ModelAvailability availability;

  ModelAvailability toEntity() => availability;
}
