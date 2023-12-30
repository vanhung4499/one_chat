import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:one_chat/utils/tracker/tracker_interface.dart';

class OneChatTrackerImpl implements OneChatTracker {
  Logger logger = Get.find();
  @override
  Future<void> trackEvent(String eventName,
      [Map<String, dynamic>? props]) async {
    logger.d("event: $eventName, props: $props");
  }
}