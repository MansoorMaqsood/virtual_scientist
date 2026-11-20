import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityChannel {
  static UnityWidgetController? _controller;

  /// Initialize Unity controller
  static void init(UnityWidgetController controller,
      {void Function(String message)? onMessage}) {
    _controller = controller;

    if (onMessage != null) {
      _controller?.onUnityMessage = (dynamic msg) {
        if (msg is String) {
          onMessage(msg);
        } else {
          onMessage(msg.toString());
        }
      };
    }
  }

  /// Send message Flutter → Unity
  static void sendToUnity(String gameObject, String method, String message) {
    if (_controller == null) {
      print("⚠️ UnityChannel: Controller not initialized");
      return;
    }

    _controller!.postMessage(gameObject, method, message);
  }
}