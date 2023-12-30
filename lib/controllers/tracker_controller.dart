import 'package:get/get.dart';
import 'package:one_chat/utils/tracker/tracker_interface.dart';

class TrackerController extends GetxController {
  List<OneChatTracker> trackers = [];

  addTracker(OneChatTracker tracker) {
    trackers.add(tracker);
  }

  Future<void> trackEvent(String eventName,
      [Map<String, dynamic>? props]) async {
    if (trackers.isNotEmpty) {
      for (OneChatTracker tracker in trackers) {
        tracker.trackEvent(eventName, props);
      }
    }
  }
}
