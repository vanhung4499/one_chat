
import 'dart:collection';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:one_chat/models/ai.dart';
import 'package:one_chat/utils/app_constants.dart';

class MessageController extends GetxController {
  LinkedHashMap<String, bool> displays = LinkedHashMap<String, bool>();

  bool isDisplay(String msgId) {
    if (displays.containsKey(msgId)) {
      if (displays[msgId]!) {
        return true;
      }
    }
    return false;
  }

  setDisplay(String msgId, bool d) {
    displays[msgId] = d;
  }

  late Offset mousePosition;

  final Map<String, AiModel> _aiModels = {};

  AiModel getAiModelbyName(String modelName) {
    if (_aiModels.containsKey(modelName)) {
      return _aiModels[modelName]!;
    } else {
      AiModel aiModel = AppConstants.getAiModel(modelName);
      _aiModels[modelName] = aiModel;
      return aiModel;
    }
  }
}
