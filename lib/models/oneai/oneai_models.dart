import 'package:dart_openai/dart_openai.dart';

class OneAIImageSize {
  String id;
  String name;
  OpenAIImageSize openAIImageSize;
  OneAIImageSize({
    required this.id,
    required this.name,
    required this.openAIImageSize,
  });
}

class OneAIImageQuality {
  String id;
  String name;
  OpenAIImageQuality? openAIImageQuality;
  OneAIImageQuality({
    required this.id,
    required this.name,
    this.openAIImageQuality,
  });
}

class OneAIImageStyle {
  String id;
  String name;
  OpenAIImageStyle openAIImageStyle;
  OneAIImageStyle({
    required this.id,
    required this.name,
    required this.openAIImageStyle,
  });
}
