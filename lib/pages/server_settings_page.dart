import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/settings_server_controller.dart';
import 'package:one_chat/models/server.dart';
import 'package:one_chat/utils/app_constants.dart';
import 'package:one_chat/widgets/settings/bottom_sheet_switcher_widget.dart';
import 'package:one_chat/widgets/settings/standard_server_settings_widget.dart';

class ServerSettingsPage extends StatelessWidget {
  ServerSettingsPage({super.key});

  SettingsController settingsController = Get.find();
  SettingsServerController settingsServerController = Get.find();

  List<Map<String, String>> getOptions() {
    List<Map<String, String>> options = [];
    for (ProviderModel item in AppConstants.servers) {
      options.add({'name': item.id, 'title': item.name});
    }
    return options;
  }

  String getServerTitle(String name) {
    String title = 'Please Select a server';
    for (Map<String, String> option in getOptions()) {
      if (option['name'] == name) {
        title = option['title']!;
      }
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    settingsServerController
        .switchSettings(settingsController.settings.provider);
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAI Settings'.tr),
      ),
      body: GetBuilder<SettingsServerController>(builder: ((controller) {
        return ListView(
          padding: const EdgeInsets.only(
              left: 10.0, top: 0.0, right: 20.0, bottom: 0.0),
          children: [
            const Divider(),
            ListTile(
              dense: true,
              title: Text(
                'API Server'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            StandardServerSettingsWidget(),
            // BottomSheetSwitcherWidget(
            //   title: "Server Settings",
            //   subTitle: getServerTitle(controller.defaultServer.provider),
            //   selectedValue: controller.defaultServer.provider,
            //   options: getOptions(),
            //   leadingIcon: Icons.computer_outlined,
            //   onTapCallback: (value) {
            //     // controller.provider = value;
            //     controller.switchSettings(value);
            //     controller.update();
            //     // controller.saveSettings();
            //   },
            // ),
            // switchServerSettingsWidget(controller.defaultServer.provider)
          ],
        );
      })),
    );
  }

  Widget switchServerSettingsWidget(String provider) {
    // TODO add other server settings
    if (provider == 'openai') {
      return StandardServerSettingsWidget();
    } else if (provider == 'azure') {
      return comingSoonWidget();
    } else if (provider == 'gemini') {
      return comingSoonWidget();
    }
    return const SizedBox();
  }

  Widget comingSoonWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text("This feature will coming soon!".tr)),
    );
  }
}
