import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:one_chat/models/locale.dart';
import 'package:one_chat/utils/app_constants.dart';

class TranslationController extends GetxController {
  final Map<String, Map<String, String>> keys = {};
  initTranslations() async {
    for (LocaleModel lang in AppConstants.locales) {
      String transFile = "assets/locales/${lang.lang}.json";
      String json = await rootBundle.loadString(transFile);
      keys[lang.lang] =
          Map.castFrom<String, dynamic, String, String>(jsonDecode(json));
    }
  }
}