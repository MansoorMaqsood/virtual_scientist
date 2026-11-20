import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class ARPage extends StatefulWidget {
  final String className;
  final String subject;

  const ARPage({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  State<ARPage> createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> {
  UnityWidgetController? _unityController;
  bool _unityReady = false;
  String _status = "Unity is loading...";

  /// Handle messages coming from Unity
  void _onUnityMessage(dynamic message) {
    debugPrint("📩 From Unity: $message");

    try {
      final data = jsonDecode(message ?? '{}');
      final evt = data['event'];

      if (evt == 'ready') {
        setState(() {
          _unityReady = true;
          _status = "Unity AR is active";
        });
      } else if (evt == 'spawned') {
        setState(() => _status = "Spawned: ${data['prefab']}");
      } else if (evt == 'hint') {
        setState(() => _status = data['text']);
      }
    } catch (e) {
      debugPrint("⚠️ Could not parse Unity message: $message → $e");
    }
  }

  /// Send command to Unity
  void _sendToUnity(String cmd, String prefab) {
    if (_unityController == null) return;

    final msg = jsonEncode({
      "cmd": cmd,
      "prefab": prefab,
      "nx": 0.5,
      "ny": 0.5,
    });

    _unityController!.postMessage(
      'GameManager', // GameObject name in Unity
      'OnFlutterMessage', // Method name in Unity
      msg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("${widget.subject} AR"),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// Unity view
          UnityWidget(
            onUnityCreated: (controller) => _unityController = controller,
            onUnityMessage: _onUnityMessage,
            fullscreen: true,
            unloadOnDispose: false, // 👈 keeps Unity alive
          ),

          /// Status overlay
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_unityReady)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                        strokeWidth: 2.5,
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Floating spawn buttons
          if (_unityReady)
            Positioned(
              right: 16,
              bottom: 24,
              child: Column(
                children: [
                  _buildSpawnButton("Microscope", "microscope"),
                  const SizedBox(height: 12),
                  _buildSpawnButton("Slide", "slide"),
                  const SizedBox(height: 12),
                  _buildSpawnButton("Listeria", "listeria"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpawnButton(String label, String prefab) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 6,
      ),
      onPressed: () => _sendToUnity("spawn", prefab),
      icon: const Icon(Icons.add, size: 20, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
