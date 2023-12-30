import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/chat_message_controller.dart';
import 'package:one_chat/controllers/chat_session_controller.dart';
import 'package:one_chat/controllers/question_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/settings_server_controller.dart';
import 'package:one_chat/controllers/tracker_controller.dart';
import 'package:one_chat/models/ai.dart';
import 'package:one_chat/models/message.dart';
import 'package:one_chat/models/session.dart';
import 'package:one_chat/utils/app_constants.dart';
import 'package:one_chat/utils/input_submit_utils.dart';
import 'package:one_chat/widgets/chat/message_widget.dart';
import 'package:one_chat/widgets/chat/question_input_widget.dart';

class ChatMessagePage extends StatelessWidget {
  late ChatMessageController chatMessageController;
  SettingsController settingsController = Get.find();
  Logger logger = Get.find<Logger>();
  TrackerController tracker = Get.find();
  ChatMessagePage({super.key}) {
    var data = Get.parameters;
    sid = data['sid'];
    logger.d("ChatMessageController: $sid ");
    chatMessageController = Get.find<ChatMessageController>();
    session = chatSessionController.getSessionBySid(sid!);
    chatMessageController.findBySessionId(sid);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // scrollController.addListener(() {
      //   scrollButtonListener();
      // });
      // scrollButtonListener();
      // questionInputController.inputFocus.requestFocus();
    });
  }

  late SessionModel session;

  // late SessionModel session;
  late String? sid;

  ChatSessionController chatSessionController =
  Get.find<ChatSessionController>();
  TextEditingController textEditingController = TextEditingController();

  scrollToBottom({animate = true}) async {
    int duration = 10;
    if (animate) {
      duration = 500;
    }
    await scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
  }

  ScrollController scrollController = ScrollController();
  QuestionController questionController = Get.find();
  SettingsServerController settingsServerController = Get.find();

  final double radius = 14;

  Future<void> onSubmit(ChatMessageController controller) async {
    await InputSubmitUtils.instance.submitInput(
        chatSessionController,
        chatMessageController,
        settingsServerController,
        questionController);
    tracker.trackEvent("chat", {"uuid": settingsController.settings.uuid});
  }

  handelMenuClick(int item, BuildContext context) {
    logger.d("handelMenuClick: $item");
    if (item == 0) {
      Get.toNamed('/editchat', parameters: {
        'opt': 'edit',
        'sid': chatSessionController.currentSession.sid
      })!
          .then((value) {
        logger.d("edit return");
        chatSessionController.update();
      });
    } else if (item == 1) {
      Get.defaultDialog(
        title: "Clean Session".tr,
        onCancel: () {
          Get.back();
        },
        onConfirm: () {
          // onDelete(message);
          chatMessageController
              .cleanSessionMessages(chatSessionController.currentSession.sid);
          chatMessageController.update();
          Get.back();
        },
        textCancel: "Cancel".tr,
        textConfirm: "Confirm".tr,
        middleText: "Confirm clean session?".tr,
        radius: 5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("messages.length: ${messages.length}");
    // SessionModel session = chatListController.getSessionBySid(sid);
    AiModel aiModel = AppConstants.getAiModel(session.model);
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ChatSessionController>(builder: (controller) {
          return Text(controller.currentSession.name);
        }),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) {
              handelMenuClick(item, context);
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.edit),
                    title: Text("Edit".tr),
                  )),
              PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.cleaning_services),
                    title: Text("Clean".tr),
                  )),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GetBuilder<ChatMessageController>(builder: (controller) {
                return ListView.builder(
                  reverse: true,
                  itemCount: controller.messages.length,
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext ctx, int index) {
                    return MessageContent(
                        message: controller.messages.elementAt(index),
                        deviceType: settingsController.deviceType,
                        session: session,
                        aiModel: aiModel,
                        onQuote: (MessageModel message) {},
                        onDelete: (MessageModel message) {},
                        moveTo: (MessageModel message) {});
                  },
                );
              }),
            ),
            QuestionInputPanelWidget(
              sid: sid!,
              scrollToBottom: scrollToBottom,
              questionController: questionController,
              session: chatSessionController.currentSession,
              onQuestionInputSubmit: () async {
                logger.d("onSubmit");
                await onSubmit(chatMessageController);
              },
              settingsController: settingsController,
              settingsServerController: settingsServerController,
            ),
          ],
        ),
      ),
    );
  }
}
