import 'dart:async';

class AppEventBus {
  static final StreamController<String> _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void fire(String event) => _controller.add(event);
}
