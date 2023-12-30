import 'package:dart_openai/dart_openai.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/controllers/chat_message_controller.dart';
import 'package:one_chat/controllers/chat_session_controller.dart';
import 'package:one_chat/controllers/question_controller.dart';
import 'package:one_chat/controllers/settings_server_controller.dart';
import 'package:one_chat/models/ai.dart';
import 'package:one_chat/models/message.dart';
import 'package:one_chat/models/server.dart';
import 'package:one_chat/models/session.dart';
import 'package:one_chat/utils/app_constants.dart';
import 'package:one_chat/utils/one_ai_utils.dart';
import 'package:one_chat/utils/utils.dart';
import 'package:uuid/uuid.dart';

class InputSubmitUtils {
  InputSubmitUtils._();

  static final InputSubmitUtils _instance = InputSubmitUtils._();
  static InputSubmitUtils get instance => _instance;

  final Logger logger = Get.find();

  Future<void> submitChatModel(
      ChatMessageController chatMessageController,
      ChatSessionController chatSessionController,
      QuestionController questionController,
      SettingsServerController settingsServerController,
      ) async {
    String model = chatSessionController.currentSession.model;
    AiModel aiModel = AppConstants.getAiModel(model);

    /// Create a message entered by the user
    MessageModel userMessage = MessageModel(
      msgId: const Uuid().v4(),
      role: MessageRole.user.name,
      content: questionController.inputText,
      sId: chatSessionController.currentSession.sid,
      model: chatSessionController.currentSession.model,
      msgType: 1,
      synced: false,
      generating: false,
      updated: getCurrentDateTime(),
    );

    if (aiModel.enableImage != null && aiModel.enableImage == true) {
      // userMessage.inputImageUrls.add(questionInputController.questionInputModel)
      if (questionController.questionInputModel.hasUploadImage) {
        userMessage.imageUrl =
            questionController.questionInputModel.uploadImage;
      }
    }

    try {
      late var openai;

      String provider = settingsServerController.defaultServer.provider;
      logger.d("provider: $provider , $model");

      openai = OneAIUtils.instance
            .getOpenaiInstance(settingsServerController.defaultServer);

      Stream<OpenAIStreamChatCompletionModel> chatCompletionStream =
      openai.chat.createStream(
        model: model,
        messages: getChatRequestMessages(
            chatMessageController.messages,
            chatSessionController.currentSession,
            userMessage,
            aiModel,
            questionController.questionInputModel.quotedMessages),
        // toolChoice: "auto",
        temperature: chatSessionController.currentSession.temperature,
        maxTokens: aiModel.maxTokens,
        // responseFormat: {"type": "json_object"},
        // user:
        // seed: 6, //https://platform.openai.com/docs/api-reference/chat/create
      );

      /// add quotes in the user message
      if (questionController
          .questionInputModel.quotedMessages.isNotEmpty) {
        userMessage.quotes = [];
        for (MessageModel msg
        in questionController.questionInputModel.quotedMessages) {
          userMessage.quotes!.add(msg.msgId);
        }
      }

      /// Put the message into the list. Here you need to first calculate the historical messages and then add userMessage to the sessions list.
      chatMessageController.addMessage(userMessage);
      chatMessageController.update();

      /// create Assistant Message
      MessageModel targetMessage = MessageModel(
        msgId: const Uuid().v4(),
        role: MessageRole.assistant.name,
        content: "",
        sId: chatSessionController.currentSession.sid,
        model: chatSessionController.currentSession.model,
        msgType: 1,
        synced: false,
        updated: getCurrentDateTime() + 1,
        generating: true,
      );
      chatMessageController.addMessage(targetMessage);
      chatMessageController.update();
      chatCompletionStream.listen((event) {
        logger.d("chat completion event: ${event.toString()} ");
        if (event.choices.isNotEmpty) {
          final List<OpenAIChatCompletionChoiceMessageContentItemModel>?
          content = event.choices.first.delta.content;
          // targetMessage.content = content;
          if (content != null) {
            for (OpenAIChatCompletionChoiceMessageContentItemModel item
            in content) {
              targetMessage.content =
              "${targetMessage.content}${item.text ?? ''}";
              logger.d("target message: ${targetMessage.content}");
              if (targetMessage.generating == true) {
                targetMessage.streamContent = targetMessage.content;
              }
            }
          }
        }
      }, onDone: () {
        logger.d("stream message is done");
        targetMessage.generating = false;
        targetMessage.closeStream();
        logger.d("user message: ${userMessage.imageUrls} ");
        chatMessageController.saveMessage(userMessage);
        targetMessage.updated = getCurrentDateTime() + 1;
        chatMessageController.saveMessage(targetMessage);
        chatSessionController
            .updateSessionLastEdit(chatSessionController.currentSession);
        chatSessionController.update();
      }, onError: (error) {
        logger.e("stream error: $error");
        targetMessage.content = "Error: ${error.message}";
        chatMessageController.update();
        targetMessage.closeStream();
        // TODO process error.
      });
    } on RequestFailedException catch (e) {
      logger.e("error: $e");
      // TODO process exception
    } on Exception catch (e) {
      logger.e("getOpenAIInstance error: $e");
    }
  }

  List<OpenAIChatCompletionChoiceMessageModel> getChatRequestMessages(
      List<MessageModel> historyMessages,
      SessionModel currentSession,
      MessageModel userMessage,
      AiModel aiModel,
      [List<MessageModel>? quotedMessages]) {
    List<OpenAIChatCompletionChoiceMessageModel> messages = [];
    messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              currentSession.prompt.content)
        ]));
    messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              userMessage.content),
          if (aiModel.enableImage != null &&
              aiModel.enableImage == true &&
              userMessage.hasImage)
            OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                userMessage.imageUrl),
        ]));

    /// Count tokens
    int totalTokens = currentSession.maxContextSize -
        numTokenCounter(currentSession.model, currentSession.prompt.content);
    totalTokens = totalTokens -
        numTokenCounter(currentSession.model, userMessage.content);

    /// Maximum number of historical messages
    int totalMessageCount = currentSession.maxContextMsgCount;
    //TODO: deal with quoted messsages
    if (quotedMessages != null && quotedMessages.isNotEmpty) {
      for (int i = 0; i < quotedMessages.length; i++) {
        MessageModel quoteMessage = quotedMessages[i];
        // for (MessageModel quoteMessage in quotedMessages) {
        messages.insert(
            1,
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.user,
                content: [
                  if (aiModel.enableImage != null &&
                      aiModel.enableImage == true &&
                      quoteMessage.hasImage)
                    OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                        quoteMessage.imageUrl),
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                      quoteMessage.content),
                ]));
      }
      return messages;
    }

    for (MessageModel message in historyMessages) {
      totalTokens =
          totalTokens - numTokenCounter(currentSession.model, message.content);
      totalMessageCount -= 1;
      if (totalTokens < 0) {
        break;
      } else if (totalMessageCount <= 0 &&
          currentSession.maxContextMsgCount != 22) {
        /// 22 is unlimited count
        break;
      } else {
        // logger.d(OpenAIChatMessageRole.values
        //     .firstWhere((e) => e.name == message.role));
        messages.insert(
            1,
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.values
                    .firstWhere((e) => e.name == message.role),
                content: [
                  if (aiModel.enableImage != null &&
                      aiModel.enableImage == true &&
                      message.hasImage)
                    OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                        message.imageUrl),
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                      message.content),
                ]));
      }
    }

    return messages;
  }

  errorHandler(
      ChatSessionController chatSessionController,
      ChatMessageController chatMessageController,
      SettingsServerController settingsServerController,
      QuestionController questionController,
      String errorMsg) {
    MessageModel userMessage = MessageModel(
      msgId: const Uuid().v4(),
      role: MessageRole.user.name,
      content: questionController.inputText,
      sId: chatSessionController.currentSession.sid,
      model: chatSessionController.currentSession.model,
      msgType: 1,
      synced: false,
      generating: false,
      updated: getCurrentDateTime(),
    );

    chatMessageController.addMessage(userMessage);
    chatMessageController.update();

    MessageModel targetMessage = MessageModel(
      msgId: const Uuid().v4(),
      role: MessageRole.assistant.name,
      content: errorMsg,
      sId: chatSessionController.currentSession.sid,
      model: AppConstants.aiModels[0].modelName,
      msgType: 1,
      synced: false,
      generating: false,
      updated: getCurrentDateTime() + 5,
    );

    chatMessageController.addMessage(targetMessage);
    chatMessageController.update();
  }

  oldChatFunction(
      ChatSessionController chatSessionController,
      ChatMessageController chatMessageController,
      SettingsServerController settingsServerController,
      QuestionController questionController) async {
    chatMessageController.inputQuestion = questionController.inputText;
    // chatMessageController.quoteMessages =
    //     questionInputController.questionInputModel.quotedMessages;
    chatMessageController.submit(chatSessionController.currentSession.sid,
        onDone: () {
          chatMessageController.inputQuestion = "";
          chatSessionController
              .updateSessionLastEdit(chatSessionController.currentSession);
          chatSessionController.update();
        }, onError: () {});
  }

  /// TODO needs to be refactored, use the model definition supported by the server to write logic
  Future<void> submitInput(
      ChatSessionController chatSessionController,
      ChatMessageController chatMessageController,
      SettingsServerController settingsServerController,
      QuestionController questionController) async {
    logger.d(
        "call submitInput ${settingsServerController.defaultServer.provider}");
    AiModel aiModel =
    AppConstants.getAiModel(chatSessionController.currentSession.model);
    String provider = settingsServerController.defaultServer.provider;

    /// validate server configure
    if (settingsServerController.provider.isEmpty ||
        settingsServerController.defaultServer.getApiKey(aiModel).isEmpty ||
        settingsServerController.defaultServer
            .getBaseUrlByModel(aiModel.modelName)
            .isEmpty) {
      errorHandler(
          chatSessionController,
          chatMessageController,
          settingsServerController,
          questionController,
          "The server configuration is incorrect.".tr);
      return;
    }

    logger.d("aitype: ${aiModel.aiType}");

    ProviderModel providerModel = AppConstants.getProvider(provider);
    if (providerModel.supportedModels.contains(aiModel.modelName)) {
      if (chatSessionController.currentSession.modelType ==
          ModelType.chat.name) {
        if (aiModel.aiType == AiType.bard) {
          oldChatFunction(chatSessionController, chatMessageController,
              settingsServerController, questionController);
          return;
        } else {
          await InputSubmitUtils.instance.submitChatModel(
              chatMessageController,
              chatSessionController,
              questionController,
              settingsServerController);
        }
      } else if (chatSessionController.currentSession.modelType ==
          ModelType.text.name) {
        // TODO process text model
      } else {
        /// process error
        errorHandler(
            chatSessionController,
            chatMessageController,
            settingsServerController,
            questionController,
            "The current server does not support this model. If you need to use all models, it is recommended to use the One Chat server."
                .tr);
      }
      questionController.clear();
      questionController.update();
    } else {
      errorHandler(
          chatSessionController,
          chatMessageController,
          settingsServerController,
          questionController,
          "The current server does not support this model. If you need to use all models, it is recommended to use the One Chat server."
              .tr);
    }
  }
}