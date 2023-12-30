import 'package:dart_openai/dart_openai.dart';
import 'package:one_chat/models/server.dart';

class OneAIUtils {
  static final OneAIUtils _oneAIUtils = OneAIUtils._();

  static OneAIUtils get instance => _oneAIUtils;

  ServerModel? defaultServer;

  OpenAI getOpenaiInstance(ServerModel defaultServer) {
    defaultServer = defaultServer;
    OpenAI.apiKey = defaultServer.apiKey;
    OpenAI.baseUrl = defaultServer.apiHost;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
    OpenAI.showLogs = debug;
    OpenAI.showResponsesLogs = debug;
    return OpenAI.instance;
  }

  OpenAI getOneChatInstance(ServerModel defaultServer) {
    return getOpenaiInstance(defaultServer);
  }

  OneAIUtils._();

  initOpenAI(ServerModel defaultServer, {String? model}) {
    OpenAI.apiKey = defaultServer.apiKey;
    OpenAI.baseUrl = defaultServer.apiHost;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
    OpenAI.showLogs = debug;
    OpenAI.showResponsesLogs = debug;
    return OpenAI.instance;
  }

  bool debug = true;
}
