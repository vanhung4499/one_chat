
import 'dart:convert';

import 'package:one_chat/utils/app_constants.dart';

import 'ai.dart';

class ProviderModel {
  ProviderModel(
      {required this.id,
        required this.name,
        required this.baseUrl,
        required this.supportedModels});
  String id;
  String name;
  String baseUrl;
  List<String> supportedModels;

  String get url {
    return baseUrl;
  }
}

class ServerModel {
  String provider;
  String apiHost;
  String apiKey;
  String license;
  String deploymentId;
  bool isActive;
  String message = '';
  // bool error = false;
  Map<String, Map<String, String>> azureConfig = {};
  String azureApiVersion = "2023-05-15";

  ServerModel({
    required this.provider,
    this.apiHost = '',
    this.apiKey = '',
    this.license = '',
    this.deploymentId = '',
    this.isActive = false,
  }) {
    if (azureConfig.isEmpty) {
      azureConfig = {
        "gpt-3.5-turbo": {
          "name": "gpt-3.5-turbo",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
          // "apiVersion": "",
        },
        "gpt-3.5-turbo-16k": {
          "name": "gpt-3.5-turbo-16k",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
          // "apiVersion": "",
        },
        "gpt-4": {
          "name": "gpt-4",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
          // "apiVersion": "",
        },
        "gpt-4-32k": {
          "name": "gpt-4-32k",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
          // "apiVersion": "",
        },
        "dall-e-3": {
          "name": "gpt-4-32k",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
        },
        "gpt-4-vision-preview": {
          "name": "gpt-4-vision-preview",
          "apiKey": "",
          "deploymentId": "",
          "url": "",
        }
      };
    }
  }

  Map<String, String> getAzureModelSettings(String modelName) {
    return azureConfig[modelName]!;
  }

  String getRequestURL(String modelName) {
    return "$apiHost/v1/chat/completions";
  }

  String getRequestUrlForOpenaiDart(String modelName) {
    return "$apiHost/v1/chat/completions";
  }

  String getApiKey(AiModel model) {
    return apiKey;
  }

  String getApiKeyByModel(String modelName) {
    return apiKey;
  }

  String getDeploymentIdByModel(String modelName) {
    //deploymentId
    Map<String, String> modelSettings = getAzureModelSettings(modelName);
    if (modelSettings.containsKey("deploymentId")) {
      return "${modelSettings['deploymentId']}";
    }
    return "No deploymentId";
  }

  String getBaseUrlByModel(String modelName) {
    if (provider == "azure") {
      Map<String, String> modelSettings = getAzureModelSettings(modelName);
      if (modelSettings.containsKey("url")) {
        return "${modelSettings['url']}";
      }
    }
    return apiHost;
  }

  String getApiVersion(String modelName) {
    return AppConstants.azureAPIVersion;
  }

  String getRequestURLByModel(AiModel model) {
      // apiHost = "https://api2.fucklina.com";
      if (model.aiType == AiType.bard) {
        return "$apiHost/app/gbard";
      } else {
        return "$apiHost/v1/chat/completions";
      }
  }

  Map<String, String> getRequestHeaders(AiModel model) {
    return {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      // 'Accept-Language': settingsController.lang
    };
  }

  setModelSettings(String modelName, String deploymentId, String url) {
    azureConfig[modelName] = {
      "name": modelName,
      "deploymentId": deploymentId,
      "apiKey": apiKey,
      "url": url
    };
  }

  factory ServerModel.fromJson(Map<String, dynamic> jsonObj) {
    ServerModel serverModel = ServerModel(
      provider: jsonObj['provider']!,
      apiHost: jsonObj['apiHost']!,
      apiKey: jsonObj['apiKey']!,
      license: jsonObj['license']!,
      deploymentId: jsonObj['deploymentId']!,
      isActive: jsonObj['isActive']!,
    );
    return serverModel;
  }

  factory ServerModel.fromJsonStr(String jsonStr) {
    Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    return ServerModel.fromJson(jsonObj);
  }

  Map<String, dynamic> toJson() => {
    "provider": provider,
    "apiHost": apiHost,
    "apiKey": apiKey,
    "license": license,
    "deploymentId": deploymentId,
    "isActive": isActive,
    "azureConfig": azureConfig,
    "azureApiVersion": azureApiVersion,
  };
}