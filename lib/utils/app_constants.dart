import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_chat/models/ai.dart';
import 'package:one_chat/models/locale.dart';
import 'package:one_chat/models/oneai/oneai_models.dart';
import 'package:one_chat/models/server.dart';
import 'package:one_chat/models/theme.dart';

enum ImageModelType { create, edit, variation }

class AppConstants {
  static String openAIHost = "https://api.openai.com";
  static LocaleModel defaultLocale = locales[0];

  static String azureAPIVersion = "2023-12-01-preview";

  static String get appServerHost {
    String host = "https://capi.fucklina.com";
    if (kDebugMode) {
      host = "https://api2.fucklina.com";
    }
    return host;
  }

  // https://emojipedia.org/flags/
  static List<LocaleModel> locales = [
    LocaleModel(
      imageIcon: "🇺🇸",
      languageName: "English",
      languageCode: "en",
      countryCode: "US",
      // scriptCode: "",
      languageStr: "en_US",
    ),
    LocaleModel(
      imageIcon: "🇻🇳",
      languageName: "Vietnamese",
      languageCode: "vi",
      countryCode: "VN",
      // scriptCode: "",
      languageStr: "vi_VN",
    )
  ];

  static List<AiGroup> aiGroups = [
    AiGroup(
        aiType: AiType.chatgpt,
        groupName: "ChatGPT",
        groupDesc: "OpenAI ChatGPT"),
    AiGroup(
        aiType: AiType.google,
        groupName: "Google Gemini",
        groupDesc: "Google Gemini AI"),
    AiGroup(
        aiType: AiType.bard,
        groupName: "Google Vertex AI",
        groupDesc: "Google Vertex AI"),
  ];

  static List<AiModel> aiModels = [
    AiModel(
      modelName: 'gpt-3.5-turbo',
      alias: ['gpt-3.5'],
      aiType: AiType.chatgpt,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 4000,
      modelMaxContextSize: 4000,
      // maxTokens: 4096,
    ),
    AiModel(
      modelName: 'gpt-3.5-turbo-16k',
      alias: ['gpt-3.5-16k'],
      aiType: AiType.chatgpt,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 10000,
      modelMaxContextSize: 16000,
      // maxTokens: 6000,
    ),
    AiModel(
      modelName: 'gpt-4',
      alias: ['gpt-4'],
      aiType: AiType.chatgpt,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 4000,
      modelMaxContextSize: 4000,
      // maxTokens: 1000000,
    ),
    AiModel(
      modelName: 'gpt-4-32k',
      alias: ['gpt-4-32k'],
      aiType: AiType.chatgpt,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 15000,
      modelMaxContextSize: 15000,
      // maxTokens: 15000,
    ),
    AiModel(
        modelName: 'gpt-4-vision-preview',
        alias: ['gpt-4-vision-preview', 'gpt-4-vision'],
        aiType: AiType.chatgpt,
        modelType: ModelType.chat,
        temperature: 0.7,
        maxContextSize: 15000,
        modelMaxContextSize: 15000,
        maxTokens: 4096,
        enableImage: true,
        maxContextMsgCount: 8),
    AiModel(
      modelName: 'chat-bison',
      alias: ['chat-bison'],
      aiType: AiType.bard,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 7000,
      modelMaxContextSize: 8192,
      // maxTokens: 8192,
    ),
    AiModel(
      modelName: 'codechat-bison',
      alias: ['codechat-bison'],
      aiType: AiType.bard,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 5000,
      modelMaxContextSize: 6144,
      // maxTokens: 8192,
    ),
    AiModel(
      modelName: 'chat-bison-32k',
      alias: ['chat-bison-32k'],
      aiType: AiType.bard,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 15000,
      modelMaxContextSize: 15000,
      // maxTokens: 32000,
    ),
    AiModel(
      modelName: 'codechat-bison-32k',
      alias: ['codechat-bison-32k'],
      aiType: AiType.bard,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 15000,
      modelMaxContextSize: 15000,
      // maxTokens: 32000,
    ),
    AiModel(
      modelName: 'dall-e-3',
      alias: ['dall-e-3'],
      aiType: AiType.chatgpt,
      modelType: ModelType.image,
      temperature: 1,
      maxContextSize: 0,
      modelMaxContextSize: 0,
      // maxTokens: 0,
    ),
    AiModel(
      modelName: 'gemini-pro',
      alias: ['gemini-pro'],
      aiType: AiType.google,
      modelType: ModelType.chat,
      temperature: 0.7,
      maxContextSize: 2048,
      modelMaxContextSize: 2048,
      disablePrompt: true,
      // maxTokens: 0,
    ),
  ];

  static AiModel getAiModel(String modelName) {
    for (AiModel model in AppConstants.aiModels) {
      if (modelName == model.modelName) {
        return model;
      } else if (model.alias.contains(modelName)) {
        return model;
      }
    }
    return AppConstants.aiModels[0];
  }

  static List<String> get geminiModelNameList {
    List<String> list = [];
    for (AiModel model in aiModels) {
      if (model.aiType == AiType.google) {
        list.add(model.modelName);
      }
    }
    return list;
  }

  static List<String> get allModelNameList {
    List<String> list = [];
    for (AiModel model in aiModels) {
      list.add(model.modelName);
    }
    return list;
  }

  static List<String> get oneChatModelNameList {
    List<String> list = [];
    list.addAll(openaiModelNameList);
    list.addAll(vertexModelNameList);
    list.addAll(geminiModelNameList);
    return list;
  }

  static List<String> get openaiModelNameList {
    List<String> list = [];
    for (AiModel model in aiModels) {
      if (model.aiType == AiType.chatgpt) {
        list.add(model.modelName);
      }
    }
    return list;
  }

  static List<String> get azureModelNameList {
    List<String> list = [];
    for (AiModel model in aiModels) {
      if (model.aiType == AiType.chatgpt) {
        list.add(model.modelName);
      }
    }
    return list;
  }

  static List<String> get vertexModelNameList {
    List<String> list = [];
    for (AiModel model in aiModels) {
      if (model.aiType == AiType.bard) {
        list.add(model.modelName);
      }
    }
    return list;
  }

  static List<ProviderModel> servers = [
    ProviderModel(
      id: "openai",
      name: "OpenAI",
      baseUrl: "https://api.openai.com",
      supportedModels: openaiModelNameList,
    ),
    ProviderModel(
      id: "azure",
      name: "Azure API",
      baseUrl: "",
      supportedModels: openaiModelNameList,
    ),
    ProviderModel(
        id: "gemini",
        name: "Google Gemini",
        baseUrl: "https://generativelanguage.googleapis.com",
        supportedModels: geminiModelNameList
    ),
  ];
  static ProviderModel getProvider(String providerId) {
    for (ProviderModel provider in servers) {
      if (provider.id == providerId) {
        return provider;
      }
    }
    return servers[0];
  }

  static List<OCThemeMode> themeModes = [
    OCThemeMode(name: 'System', themeMode: ThemeMode.system),
    OCThemeMode(name: 'Dark', themeMode: ThemeMode.dark),
    OCThemeMode(name: 'Light', themeMode: ThemeMode.light),
  ];

  static List<OneAIImageSize> dalle3ImageSizes = [
    OneAIImageSize(
        id: '1024x1024',
        name: '1024x1024',
        openAIImageSize: OpenAIImageSize.size1024),
    OneAIImageSize(
        id: '1792x1024',
        name: '1792x1024',
        openAIImageSize: OpenAIImageSize.size1792Horizontal),
    OneAIImageSize(
        id: '1024x1792',
        name: '1024x1792',
        openAIImageSize: OpenAIImageSize.size1792Vertical),
  ];
  static OneAIImageSize getOneAIImageSize(String sizeId) {
    for (OneAIImageSize size in dalle3ImageSizes) {
      if (size.id == sizeId) {
        return size;
      }
    }
    return defaultDall3ImageSize;
  }

  static OneAIImageSize defaultDall3ImageSize = dalle3ImageSizes[0];

  static List<OneAIImageQuality> dalle3ImageQualities = [
    OneAIImageQuality(id: 'standard', name: 'standard'),
    OneAIImageQuality(
        id: 'hd', name: 'hd', openAIImageQuality: OpenAIImageQuality.hd),
  ];
  static OneAIImageQuality defaultDall3ImageQuality =
  dalle3ImageQualities[0];
  static OneAIImageQuality getOneAIImageQuality(String qualityId) {
    for (OneAIImageQuality quality in dalle3ImageQualities) {
      if (quality.id == qualityId) {
        return quality;
      }
    }
    return defaultDall3ImageQuality;
  }

  static List<OneAIImageStyle> dalle3ImageStyles = [
    OneAIImageStyle(
        id: 'natural',
        name: 'natural',
        openAIImageStyle: OpenAIImageStyle.natural),
    OneAIImageStyle(
        id: 'vivid', name: 'vivid', openAIImageStyle: OpenAIImageStyle.vivid),
  ];
  static OneAIImageStyle getOneAIImageStyle(String styleId) {
    for (OneAIImageStyle style in dalle3ImageStyles) {
      if (style.id == styleId) {
        return style;
      }
    }
    return defaultDall3ImageStyle;
  }

  static OneAIImageStyle defaultDall3ImageStyle = dalle3ImageStyles[0];

  static List<int> dalle3ImageN = [1, 2, 4];
  static int defaultDall3ImageN = dalle3ImageN[0];
}