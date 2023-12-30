import 'package:get/get.dart';

extension OneTrans on String {
  // Checks whether the language code and country code are present, and
  // whether the key is also present.
  bool get _fullLocaleAndKey {
    return Get.translations.containsKey("${Get.locale}");
  }

  // Checks if there is a callback language in the absence of the specific
  // country, and if it contains that key.
  Map<String, String>? get _getSimilarLanguageTranslation {
    final translationsWithNoCountry = Get.translations
        .map((key, value) => MapEntry(key.split("_").first, value));
    final containsKey = translationsWithNoCountry
        .containsKey(Get.locale!.languageCode.split("_").first);

    if (!containsKey) {
      return null;
    }

    return translationsWithNoCountry[Get.locale!.languageCode.split("_").first];
  }

  String get tra {
    // print('language');
    // print(Get.locale!.languageCode);
    // print('contains');
    // print(Get.translations.containsKey(Get.locale!.languageCode));
    // print(Get.translations.keys);
    // Returns the key if locale is null.
    if (Get.locale?.languageCode == null) return this;

    if (_fullLocaleAndKey) {
      print("${Get.locale!.languageCode}_${Get.locale!.countryCode}");
      return Get.translations["${Get.locale}"]![this]!;
    }
    final similarTranslation = _getSimilarLanguageTranslation;
    if (similarTranslation != null && similarTranslation.containsKey(this)) {
      return similarTranslation[this]!;
      // If there is no corresponding language or corresponding key, return
      // the key.
    } else if (Get.fallbackLocale != null) {
      final fallback = Get.fallbackLocale!;
      final key = "${fallback.languageCode}_${fallback.countryCode}";

      if (Get.translations.containsKey(key) &&
          Get.translations[key]!.containsKey(this)) {
        return Get.translations[key]![this]!;
      }
      if (Get.translations.containsKey(fallback.languageCode) &&
          Get.translations[fallback.languageCode]!.containsKey(this)) {
        return Get.translations[fallback.languageCode]![this]!;
      }
      return this;
    } else {
      return this;
    }
  }
}

