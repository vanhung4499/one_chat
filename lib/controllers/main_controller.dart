import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/locale_controller.dart';
import 'package:one_chat/models/prompt.dart';
import 'package:one_chat/repositories/localstore_repository.dart';
import 'package:one_chat/services/http_service.dart';
import 'package:one_chat/utils/utils.dart';

class MainController extends GetxController {
  static MainController get to => Get.find();
  Logger logger = Get.find();
  final LocalStoreRepository _localStoreRepository = Get.find();
  final LocaleController localeController = Get.find();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  int _navIndex = 0;

  final menus = [
    {"title": "Chat"},
    {"title": "Prompts"},
    {"title": "Settings"}
  ];

  int get navIndex {
    return _navIndex;
  }

  String getTitle() {
    return "${menus[_navIndex]['title']}";
  }

  set navIndex(int index) {
    _navIndex = index;
    update();
  }

  bool get needRefreshPrompts {
    bool needRefresh = false;
    if (prompts.isEmpty) {
      needRefresh = true;
      return needRefresh;
    }
    if (promptLang == localeController.locale.id) {
      needRefresh = false;
    } else {
      return false;
    }
    logger.d("need refresh prompts: $needRefresh");
    return needRefresh;
  }

  List<PromptModel> prompts = [];
  String promptLang = '';
  Future<List<PromptModel>> initPrompts() async {
    promptLang = localeController.locale.id;
    int dateStr = getCurrentDate();
    String key = "prompts22-$dateStr-${localeController.locale.lang}";
    logger.d("initPrompts: $key prompts length: ${prompts.length}");
    String jsonStr = '';
    if (key == _localStoreRepository.getPromptsLastUpdate()) {
      jsonStr = _localStoreRepository.getPromptsJsonString();
      logger.d("get prompts from local store");
    } else {
      jsonStr = await _fetchPrompts();
      // logger.d("prompt jsonstr: $jsonStr");
      if (jsonStr.isNotEmpty) {
        _localStoreRepository.savePrompts(jsonStr);
        _localStoreRepository.updatePromptsLastUpdate(key);
        update();
      }
    }

    if (jsonStr.isNotEmpty) {
      prompts.clear();
      var jsonObj = jsonDecode(jsonStr);
      for (var item in jsonObj) {
        prompts.add(PromptModel(
            id: "${item['id']}", name: item['name'], prompt: item['prompt']));
      }
    }
    return prompts;
    // logger.d(prompts);
  }

  Future<String> _fetchPrompts() async {
    String url = "http://capi.fucklina.com/app/prompt";
    Map<String, String> headers = {
      "lang": localeController.locale.promptLang,
    };

    logger.d("fetch prompts headers: $headers");

    String responseString = await HttpClientService.getPrompts(url, headers);
    return responseString;
  }
}

