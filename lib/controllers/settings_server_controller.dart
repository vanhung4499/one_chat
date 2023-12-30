import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/models/server.dart';
import 'package:one_chat/repositories/localstore_repository.dart';
import 'package:one_chat/services/http_service.dart';

class SettingsServerController extends GetxController {
  SettingsServerController({required this.provider}) {
    switchSettings(provider);
  }

  final LocalStoreRepository _localStoreRepository = Get.find();
  final Logger logger = Logger();

  void switchSettings(String provider) {
    this.provider = provider;
    defaultServer = _localStoreRepository.getServerSettings(provider);
    // editServer = _localStoreRepository.getServerSettings(provider);
    logger.d("switchSettings: ${defaultServer.toJson()}");
    errorMessage = '';
    activeError = false;
    needReactive = false;
  }

  void saveSettings(ServerModel serverModel) {
    _localStoreRepository.saveSeverSettings(serverModel);
    switchSettings(serverModel.provider);
  }

  String provider;

  late ServerModel defaultServer;
  // late ServerModel editServer;

  /// one chat active UI controller
  String errorMessage = '';
  bool activeError = false;
  String inputLicense = '';
  bool needReactive = false;
  Future<ServerModel> activeLicense(
      String license, String uuid, String language) async {
    ServerModel serverModel = ServerModel(provider: provider, isActive: false);
    String rtnString = await HttpClientService.activeLicense(
        "https://capi.fucklina.com/activate", license, uuid, language);
    logger.d("rtn string: $rtnString");
    Map<String, dynamic> jsonObj = jsonDecode(rtnString);
    if (jsonObj.containsKey('active')) {
      serverModel.isActive = jsonObj['active'];
      serverModel.apiHost = jsonObj['baseUrl'];
      serverModel.apiKey = jsonObj['apiKey'];
      serverModel.license = license;
      serverModel.message = jsonObj['message'];
    } else {
      // serverModel.message = jsonObj['message'];
      errorMessage = jsonObj['message'];
      activeError = true;
      needReactive = true;
    }
    return serverModel;
  }
}
