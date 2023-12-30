import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/tracker_controller.dart';
import 'package:one_chat/widgets/chat_sessions_widget.dart';
import 'package:one_chat/widgets/prompt_list_widget.dart';
import 'package:one_chat/widgets/settings_widget.dart';

class HomePage extends StatelessWidget {
  SettingsController settingsController = Get.find<SettingsController>();
  MainController mainController = Get.find();
  TrackerController tracker = Get.find();
  HomePage({super.key}) {
    Get.put(PromptListWidget());
    Get.put(SettingsWidget());
    Get.put(ChatSessionsWidget());

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (settingsController.needSettings) {
        mainController.navIndex = 2;
        mainController.update();
      }
    });
  }

  Widget appBarAddChatAction(int index) {
    Widget widget = const SizedBox();
    if (index == 0) {
      widget = IconButton(
          onPressed: () {
            Get.toNamed('/editchat', parameters: {'opt': 'new', 'sid': ''});
          },
          icon: const Icon(Icons.add));
    }
    return widget;
  }

  Widget getSettingWidget() {
    return Get.find<SettingsWidget>();
  }

  Widget navigationRoute(int index) {
    Widget widget = const Text("data");
    switch (index) {
      case 0:
      // widget = Text("data $index");
        widget = Get.find<ChatSessionsWidget>();
        tracker.trackEvent(
            "Page-Home", {"uuid": settingsController.settings.uuid});
        break;
      case 1:
        widget = Get.find<PromptListWidget>();
        tracker.trackEvent(
            "Page-Prompts", {"uuid": settingsController.settings.uuid});
        break;
      case 2:
      // widget = Text("data $index");
      // break;
      default:
        widget = getSettingWidget();
        tracker.trackEvent(
            "Page-Settings", {"uuid": settingsController.settings.uuid});
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<MainController>(builder: (controller) {
          return Text(controller.getTitle().tr);
        }),
        actions: [
          GetBuilder<MainController>(builder: (controller) {
            return appBarAddChatAction(controller.navIndex);
          }),
          const SizedBox(width: 5.0)
        ],
      ),
      bottomNavigationBar: GetBuilder<MainController>(builder: (controller) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            controller.navIndex = value;
            controller.update();
          },
          currentIndex: controller.navIndex,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_rounded),
              label: 'Chat'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.smart_toy),
              label: 'Prompts'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings'.tr,
            )
          ],
        );
      }),
      body: GetBuilder<MainController>(builder: (controller) {
        return navigationRoute(controller.navIndex);
      }),
    );
  }
}