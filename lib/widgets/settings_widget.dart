
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/locale_controller.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/models/locale.dart';
import 'package:one_chat/models/theme.dart';
import 'package:one_chat/widgets/settings/bottom_sheet_switcher_widget.dart';

class SettingsWidget extends StatelessWidget {
  SettingsWidget({super.key});

  // late List<Map<String, String>> options;
  MainController mainController = Get.find();
  LocaleController localeController = Get.find();
  Logger logger = Get.find();

  List<Map<String, String>> getLanguageOptions() {
    List<Map<String, String>> options = [];
    for (LocaleModel item in localeController.locales) {
      options.add({'name': item.id, 'title': item.languageName});
    }
    return options;
  }

  List<Map<String, String>> getThemeOptions() {
    List<Map<String, String>> themeOptions = [];
    for (OCThemeMode theme in SettingsController.to.themeModes) {
      themeOptions.add({'name': theme.name, 'title': theme.name});
    }
    return themeOptions;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
        id: "setting_list",
        builder: ((controller) {
          return ListView(
            // padding: EdgeInsets.zero,
            padding: const EdgeInsets.only(
                left: 10.0, top: 0.0, right: 20.0, bottom: 0.0),
            children: getSettingMenu(controller, context),
          );
        }));
  }

  List<Widget> getSettingMenu(
      SettingsController controller, BuildContext context) {
    List<Widget> menus = [
      const Divider(),
      ListTile(
        dense: true,
        title: Text(
          'OpenAI Settings'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("OpenAI Settings".tr),
            const Text(
              "API Key, API Server ",
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        leading: const Icon(Icons.smart_toy_outlined),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () {
          // SmartSelect.single(selectedValue: selectedValue)
          Get.toNamed('/settings')!.then((value) {
            controller.update(['setting_list']);
          });
        },
      ),
      const Divider(),
      ListTile(
        dense: true,
        title: Text(
          'theme'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      BottomSheetSwitcherWidget(
        title: "Theme Settings",
        subTitle: controller.settings.theme,
        selectedValue: controller.settings.theme,
        options: getThemeOptions(),
        leadingIcon: Icons.color_lens_outlined,
        onTapCallback: (value) {
          controller.settingsTheme = value;
          controller.saveSettings();
        },
      ),
      const Divider(),
      ListTile(
        dense: true,
        title: Text(
          'Language Settings'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      BottomSheetSwitcherWidget(
        title: "Language Settings",
        subTitle: localeController.locale.languageName,
        selectedValue: localeController.locale.id,
        options: getLanguageOptions(),
        leadingIcon: Icons.language_outlined,
        onTapCallback: (value) {
          // controller.settingsLanguage = value;
          localeController.setLocale(value);
          logger.d("language: $value");
          logger.d("localeController.locale.id: ${localeController.locale.id}");
          // controller.saveSettings();
          mainController.initPrompts().then((value) {
            mainController.update();
          });

          // EventBus eventBus = Get.find();
          // eventBus.fire(SettingsController.to.getLocale(value));
        },
      ),

      /// about me
      const Divider(),
      ListTile(
        dense: true,
        title: Text(
          'About'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("About".tr),
            getVersionWidget(controller),
          ],
        ),
        leading: const Icon(Icons.info_outline),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () {
          // SmartSelect.single(selectedValue: selectedValue)
          Get.toNamed('/about');
        },
      ),
    ];
    return menus;
  }

  Widget getVersionWidget(SettingsController controller) {
    Widget widget = Text(
      "${'Version'.tr}, v${controller.packageInfo.version} ",
      style: const TextStyle(fontSize: 12),
    );
    return widget;
  }
}