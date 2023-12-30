import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_chat/controllers/settings_server_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/utils/app_constants.dart';
import 'package:one_chat/utils/utils.dart';

class StandardServerSettingsWidget extends StatelessWidget {
  StandardServerSettingsWidget({super.key});

  SettingsController settingController = Get.find();
  SettingsServerController settingsServerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsServerController>(builder: (controller) {
      return Wrap(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          ListTile(
            title: Text("Server Configuration".tr),
          ),
          // Padding(padding: paddingOnly())
          Padding(
            padding:
            const EdgeInsets.only(left: 20, top: 0, bottom: 0, right: 10),
            child: TextFormField(
              initialValue: controller.defaultServer.apiHost,
              decoration: InputDecoration(
                labelText: 'API Host',
                filled: false,
                hintText: AppConstants.openAIHost
              ),
              onChanged: (value) {
                controller.defaultServer.apiHost = value.trim();
              },
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(left: 20, top: 20, bottom: 0, right: 10),
            child: TextFormField(
              initialValue: controller.defaultServer.apiKey,
              decoration: const InputDecoration(
                labelText: 'API Key',
                filled: false,
              ),
              onChanged: (value) {
                controller.defaultServer.apiKey = value.trim();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    controller.defaultServer.isActive = false;
                    // settingsController.needReactive = true;
                    // controller.defaultServer.
                    // controller.saveSettings();
                    controller.saveSettings(controller.defaultServer);
                    settingController.settings.provider =
                        controller.defaultServer.provider;
                    settingController.saveSettings();
                    showCustomToast(
                        title: "Saved successfully!".tr, context: context);
                  },
                  child: Text('Save'.tr),
                ),
                const SizedBox(
                  width: 30,
                ),
                OutlinedButton(
                  onPressed: () {
                    // controller.resetSettings();
                    Get.back();
                  },
                  child: Text('Cancel'.tr),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
