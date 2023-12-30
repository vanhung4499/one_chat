import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:one_chat/utils/app_loading_dialog.dart';
import 'package:one_chat/utils/utils.dart';

class QuestionInputPanelWidget extends StatelessWidget {
  QuestionInputPanelWidget({
    super.key,
    required this.sid,
    required this.scrollToBottom,
    // required this.questionInputFocus,
    required this.session,
    required this.questionController,
    required this.onQuestionInputSubmit,
    required this.settingsController,
    required this.settingsServerController,
  });

  String sid;
  SessionModel session;
  Function scrollToBottom;
  Function onQuestionInputSubmit;
  // FocusNode questionInputFocus;
  QuestionController questionController;
  SettingsServerController settingsServerController;
  SettingsController settingsController;
  Logger logger = Get.find<Logger>();

  bool isImageSession() {
    bool isImage = false;
    if (session.modelType == ModelType.image.name) {
      isImage = true;
    }
    return isImage;
  }

  bool isModelEnableImage() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: GetBuilder<QuestionController>(builder: (controller) {
        return Container(
          padding: const EdgeInsets.only(top: 1, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          QuestionInputWidget(
                            sid: sid,
                            scrollToBottom: scrollToBottom,
                            // questionInputFocus:
                            //     questionInputController.inputFocus,
                            session: session,
                            onQuestionInputSubmit: onQuestionInputSubmit,
                            questionController: questionController,
                          ),
                          QuoteMessagesWidget(
                            questionController: questionController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (settingsController.deviceType.name != DeviceType.small.name)
                Container(
                  padding: const EdgeInsets.only(top: 3, bottom: 3),
                  child: Text(
                    "input tips".tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class QuestionInputWidget extends StatelessWidget {
  QuestionInputWidget({
    super.key,
    required this.sid,
    required this.scrollToBottom,
    // required this.questionInputFocus,
    required this.session,
    required this.onQuestionInputSubmit,
    required this.questionController,
  });

  String sid;
  Function scrollToBottom;
  Function onQuestionInputSubmit;
  // FocusNode questionInputFocus;
  SessionModel session;
  QuestionController questionController;

  TextEditingController textEditingController = TextEditingController();
  ChatSessionController chatSessionController = Get.find();
  SettingsController settingsController = Get.find();
  Logger logger = Get.find();
  ChatMessageController chatMessageController = Get.find();
  final TrackerController tracker = Get.find();

  KeyEventResult onKey(FocusNode focusNode, RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
        !event.isShiftPressed &&
        !event.isControlPressed &&
        !event.isAltPressed) {
      logger.d("Enter key is pressed!");
      // process submit
      // focusNode.context
      // logger.d("focusNoe.context: ${focusNode.context}");
      if (focusNode.context != null) {
        logger.d("focusNoe.context: ${focusNode.context}");
        AppLoadingProgress.start(focusNode.context!);
      }
      submit(chatMessageController).then((value) {
        if (focusNode.context != null) {
          AppLoadingProgress.stop(focusNode.context!);
        }
      });
      return KeyEventResult.handled;
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
        event.isShiftPressed) {
      logger.d("Shit + Enter is pressed!");
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  Future<void> submit(ChatMessageController controller) async {
    logger.d("on submit: ${settingsController.deviceType}");
    await scrollToBottom(animate: false);
    if (settingsController.deviceType.name == DeviceType.small.name) {
      await onQuestionInputSubmit();
      // return;
    } else if (session.modelType == ModelType.image.name) {
      await onQuestionInputSubmit();
      // return;
    } else if (session.modelType == ModelType.chat.name) {
      await onQuestionInputSubmit();
    }
    tracker.trackEvent("chat", {"uuid": settingsController.settings.uuid});
  }

  @override
  Widget build(BuildContext context) {
    questionController.inputFocus.onKey = onKey;
    return GetBuilder<ChatMessageController>(
        id: 'inputQuestion',
        builder: (controller) {
          // textEditingController.text = controller.inputQuestion;
          return TextFormField(
            controller: textEditingController,
            // initialValue: textEditingController.text,
            focusNode: questionController.inputFocus,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            // keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              suffixIcon: IconButton(
                  onPressed: () {
                    AppLoadingProgress.start(context);
                    submit(controller).then((value) {
                      AppLoadingProgress.stop(context);
                    });
                  },
                  icon: const Icon(Icons.send)),
            ),
            onChanged: (value) {
              // logger.d("onChanged $value");
              if (controller.isMessagesTooLong(controller.quoteMessages)) {
                showCustomToast(
                    title: "Too many quote messages".tr, context: context);
              }
              // controller.inputQuestion = value;
              questionController.inputText = value;
              // controller.update(['inputQuestion']);
            },
            onTap: () {
              //
            },
          );
        });
  }
}

class QuoteMessagesWidget extends StatelessWidget {
  QuoteMessagesWidget({super.key, required this.questionController});

  // ChatSessionController chatSessionController = Get.find();
  ChatMessageController chatMessageController = Get.find();
  QuestionController questionController;
  @override
  Widget build(BuildContext context) {
    if (questionController.questionInputModel.quotedMessages.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        direction: Axis.horizontal,
        textDirection: TextDirection.ltr,
        children: [
          for (MessageModel message
          in questionController.questionInputModel.quotedMessages)
            InputChip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: SizedBox(
                width: 150,
                child: Text(
                  message.content,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              deleteIcon: const Icon(Icons.cancel_outlined),
              deleteButtonTooltipMessage: "Delete".tr,
              padding: const EdgeInsets.all(0),
              onDeleted: () {
                // chatMessageController.removeQuoteMessage(message);
                questionController.removeQuotedMessage(message);
                // chatMessageController.update();
                questionController.update();
              },
            ),
        ],
      ),
    );
  }
}
