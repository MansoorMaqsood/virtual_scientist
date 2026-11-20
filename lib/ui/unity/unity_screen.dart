import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityScreen extends StatefulWidget {
  final String initialPrefab;

  const UnityScreen({super.key, required this.initialPrefab});

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  UnityWidgetController? _unityWidgetController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: UnityWidget(
        onUnityCreated: onUnityCreated,
        onUnityMessage: onUnityMessage,
        useAndroidViewSurface: false,
      ),
    );
  }

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
  }

  void onUnityMessage(message) {
    try {
      final decoded = message is String ? jsonDecode(message) : message;

      if (decoded['event'] == 'ready') {
        // Unity reports ready → send prefab selection
        final msg = {
          "cmd": "select",
          "prefab": widget.initialPrefab,
          "nx": 0.5,
          "ny": 0.5
        };

        _unityWidgetController?.postMessage(
          'ARSpawnManager',
          'OnFlutterMessage',
          jsonEncode(msg),
        );
      }
    } catch (e) {
      debugPrint("Error parsing Unity message: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_unityWidgetController == null) return;

    if (state == AppLifecycleState.resumed) {
      _unityWidgetController?.resume();
    } else if (state == AppLifecycleState.paused) {
      _unityWidgetController?.pause();
    }
  }
}
