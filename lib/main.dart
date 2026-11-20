import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtual_scientist/ui/splash_screen.dart';
import 'firebase_options.dart';

// 👇 Define global navigatorKey here
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // don’t forget this
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Scientist',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      navigatorKey: navigatorKey, // 👈 now it exists
      home: SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   // ✅ Define platform channel (must match Android side)
//   static const platform = MethodChannel('com.example.virtual_scientist/unity');

//   Future<void> _launchUnity() async {
//     try {
//       await platform.invokeMethod('launchUnity');
//     } on PlatformException catch (e) {
//       debugPrint("❌ Failed to launch Unity: ${e.message}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Flutter + Unity Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _launchUnity,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: const Text(
//             '🚀 Launch Unity Scene',
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }