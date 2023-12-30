abstract class OneChatTracker {
  Future<void> trackEvent(
      String eventName, [
        Map<String, dynamic>? props,
      ]) async {}
}
