import 'package:get/get.dart';
import 'package:one_chat/models/ai.dart';
import 'package:one_chat/models/session.dart';
import 'package:one_chat/utils/app_constants.dart';

class ChatSessionEditController extends GetxController {
  late SessionModel session;

  bool isEdit = false;

  SessionModel switchSessionModel(String modelName) {
    AiModel aiModel = AppConstants.getAiModel(modelName);
    session.model = aiModel.modelName;
    session.modelType = aiModel.modelType.name;
    session.maxContextMsgCount = aiModel.maxContextMsgCount ?? 22;
    session.maxContextSize = aiModel.maxContextSize;
    return session;
  }
}
