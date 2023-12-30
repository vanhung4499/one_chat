import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/chat_session_controller.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/tracker_controller.dart';
import 'package:one_chat/models/prompt.dart';
import 'package:one_chat/models/session.dart';

class PromptListPage extends StatelessWidget {
  Logger logger = Get.find();
  TrackerController tracker = Get.find();
  late StreamSubscription eventSub;

  PromptListPage({super.key}) {}

  MainController mainController = Get.find();
  ChatSessionController chatSessionController = Get.find();
  SettingsController settingsController = Get.find();

  double getFittedCardWidth(BuildContext context) {
    double width = 330;
    double parentWidgetWidth = MediaQuery.of(context).size.width;
    // if (parentWidgetWidth / 3)
    for (int i = 1; i <= 5; i++) {
      if ((parentWidgetWidth / i - 330) < 50) {
        width = (parentWidgetWidth / i) - 2 * i;
        break;
      }
    }
    return width;
  }

  @override
  Widget build(BuildContext context) {
    // mainController.initPrompts();
    tracker
        .trackEvent("Page-Prompts", {"uuid": settingsController.settings.uuid});
    return Scaffold(
      appBar: AppBar(
        title: Text("Prompts".tr),
      ),
      body: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        child: GetBuilder<MainController>(
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 0),
              child: Wrap(
                children: [
                  for (PromptModel promptModel in controller.prompts)
                    Container(
                      width: getFittedCardWidth(context),
                      padding: const EdgeInsets.only(bottom: 10, right: 10),
                      child: Card(
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            SessionModel sessionModel =
                            chatSessionController.createSession(
                              name: promptModel.name,
                              prompt: promptModel.prompt,
                            );
                            // // chatListController.save();
                            chatSessionController.saveSession(sessionModel);
                            // controller.navIndex = 0;
                            controller.update();
                            chatSessionController.update();
                            Get.back();
                            chatSessionController
                                .switchSession(sessionModel.sid);
                            // Get.toNamed('/chat',
                            //     parameters: {'sid': sessionModel.sid});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promptModel.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  promptModel.prompt,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}