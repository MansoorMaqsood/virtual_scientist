import 'package:flutter/material.dart';
import 'package:virtual_scientist/main.dart';
import 'package:virtual_scientist/ui/unity/unity_screen.dart';

class UnityLauncher {
  static void launchUnity(String prefab) {
    // 👇 this uses navigatorKey from main.dart
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => UnityScreen(initialPrefab: prefab),
      ),
    );
  }
}
