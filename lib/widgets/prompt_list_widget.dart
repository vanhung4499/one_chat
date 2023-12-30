import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/chat_session_controller.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/models/session.dart';

class PromptListWidget extends StatelessWidget {
  PromptListWidget({super.key});

  ChatSessionController chatSessionController = Get.find();
  MainController mainController = Get.find();
  Logger logger = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (controller) {
      return ListView.builder(
          padding: const EdgeInsets.only(
              left: 10.0, top: 0.0, right: 20.0, bottom: 0.0),
          itemCount: controller.prompts.length,
          controller: ScrollController(),
          itemBuilder: (BuildContext ctxt, int index) {
            return Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                elevation: 5,
                child: InkWell(
                  onTap: () {
                    SessionModel sessionModel =
                        chatSessionController.createSession(
                      name: controller.prompts.elementAt(index).name,
                      prompt: controller.prompts.elementAt(index).prompt,
                    );
                    // chatListController.save();
                    chatSessionController.saveSession(sessionModel);
                    controller.navIndex = 0;
                    controller.update();
                    chatSessionController.update();
                    Get.toNamed('/chat', parameters: {'sid': sessionModel.sid});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.prompts.elementAt(index).name,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          controller.prompts.elementAt(index).prompt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    });
  }
}
