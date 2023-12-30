import 'dart:convert';
import 'dart:ui';

class LocaleModel {
  LocaleModel({
    required this.imageIcon,
    required this.languageName,
    required this.languageCode,
    required this.countryCode,
    this.scriptCode,
    required this.languageStr,
  });

  String imageIcon;
  String languageName;
  String languageCode;
  String countryCode;
  String? scriptCode;

  String languageStr;

  String get id {
    return locale.toString();
  }

  Locale get locale {
    return Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode);
  }

  String get promptLang {
    if (lang == "vi_VN") {
      return "vi";
    } else if (lang == "en_US") {
      return "en";
    } else {
      return lang;
    }
  }

  String get lang {
    return "${languageCode}_$countryCode";
  }

  String toJson() {
    return jsonEncode({
      "id": id,
      "languageName": languageName,
      "languageCode": languageCode,
      "countryCode": countryCode,
      "scriptCode": scriptCode,
      "languageStr": languageStr,
    });
  }
}