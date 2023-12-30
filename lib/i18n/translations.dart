import 'package:get/get.dart';
import 'package:one_chat/controllers/translation_controller.dart';

class OneChatTranslations extends Translations {
  TranslationController translationController = Get.find();
  @override
  Map<String, Map<String, String>> get keys {
    return translationController.keys;
  }
}
