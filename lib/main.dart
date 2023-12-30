import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tiktoken/flutter_tiktoken.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/app_routes.dart';
import 'package:one_chat/controllers/chat_message_controller.dart';
import 'package:one_chat/controllers/chat_session_controller.dart';
import 'package:one_chat/controllers/chat_session_edit_controller.dart';
import 'package:one_chat/controllers/locale_controller.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/controllers/message_controller.dart';
import 'package:one_chat/controllers/question_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/settings_server_controller.dart';
import 'package:one_chat/controllers/tracker_controller.dart';
import 'package:one_chat/controllers/translation_controller.dart';
import 'package:one_chat/i18n/translations.dart';
import 'package:one_chat/repositories/localstore_repository.dart';
import 'package:one_chat/repositories/session_repository.dart';
import 'package:one_chat/utils/app_constants.dart';
import 'package:one_chat/utils/tracker/tracker_impl.dart';
import 'package:one_chat/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // print("system locale: ${Get.deviceLocale}");
  // init languages
  TranslationController trans = Get.put(TranslationController());
  await trans.initTranslations();

  await initServices();

  runApp(OneChat(
    mainRouters: appRoutes,
    trans: OneChatTranslations(),
  ));
}


initServices() async {
  await dotenv.load(fileName: ".env");

  Logger logger = Get.put(Logger());
  TrackerController trackerController = Get.put(TrackerController());
  trackerController.addTracker(OneChatTrackerImpl());

  logger.d("env: channel: ${dotenv.get('CHANNEL')}");

  String storeageName = "onechat";

  await GetStorage.init(storeageName);

  Get.put(LocalStoreRepository(storageName: storeageName));
  // Get.put(HttpClientService());
  Directory dir = await getApplicationDocumentsDirectory();
  logger.d("Application Documents Directory: $dir ");
  Get.put(SessionRepository(dir));
  SettingsController settingsController = Get.put(SettingsController());
  SettingsController.to.dataDir = dir;
  settingsController.deviceType = getDeviceType();

  /// init locale
  LocaleController localeController = Get.put(LocaleController());
  localeController.lang = settingsController.settings.language;
  localeController.detectiveLocale();
  logger.d("localeController.lang : ${localeController.lang}");
  logger.d("locale: ${localeController.locale.toJson()}");

  SettingsServerController settingsServerController = Get.put(
      SettingsServerController(provider: settingsController.settings.provider));

  MainController mainController = Get.put(MainController());
  Get.put(ChatSessionController());
  Get.put(ChatMessageController());
  Get.put(QuestionController(applicationDocumentsDirectory: dir));
  Get.put(MessageController());
  Get.put(ChatSessionEditController());

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  settingsController.packageInfo = packageInfo;

  // logger.d(dotenv.get("CHANNEL"));
  logger.d("Channel name: ${settingsController.channelName}");

  TiktokenDataProcessCenter().initata();

  mainController.initPrompts();
}

// ignore: must_be_immutable
class OneChat extends StatelessWidget {
  OneChat({super.key, required this.mainRouters, required this.trans});

  List<GetPage<dynamic>> mainRouters;
  Translations trans;
  LocaleController localeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: mainRouters,

      theme: FlexThemeData.light(
        scheme: FlexScheme.materialBaseline,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          // useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // swapLegacyOnMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.materialBaseline,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        // blendLevel: 13,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          // useM2StyleDividerInM3: true,
        ),
      ),
      // theme: ThemeData.light(useMaterial3: true),
      // darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: SettingsController.to.getThemeMode(),
      locale: localeController.locale.locale,
      supportedLocales: localeController.supportedLocales,
      localizationsDelegates: localeController.localizationsDelegates(),
      translations: trans,
      fallbackLocale: AppConstants.defaultLocale.locale,
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeft,
    );
  }
}
