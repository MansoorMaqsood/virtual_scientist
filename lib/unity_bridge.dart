import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityDemo extends StatefulWidget {
  @override
  State<UnityDemo> createState() => _UnityDemoState();
}

class _UnityDemoState extends State<UnityDemo> {
  UnityWidgetController? _unityController;

  // Called when Unity is created
  void onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
  }

  // Send a message Flutter → Unity
  void sendToUnity() {
    _unityController?.postMessage(
      'GameObjectName', // Unity GameObject name
      'MethodName',     // Method in Unity script
      'Hello from Flutter!', // Message string
    );
  }

  // Receive a message Unity → Flutter
  void onUnityMessage(dynamic message) {
    debugPrint('📩 Message from Unity: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unity Widget Example")),
      body: Column(
        children: [
          Expanded(
            child: UnityWidget(
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage,
            ),
          ),
          ElevatedButton(
            onPressed: sendToUnity,
            child: Text("Send to Unity"),
          ),
        ],
      ),
    );
  }
}