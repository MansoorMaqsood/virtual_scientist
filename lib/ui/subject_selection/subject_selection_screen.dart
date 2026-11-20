import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String className;
  const SubjectSelectionScreen({super.key, required this.className});

  static const platform = MethodChannel("com.example.virtual_scientist/unity");

  //  Launch Unity
  Future<void> _launchUnityWithUI(String uiName) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint(" Camera permission denied — cannot start Unity.");
      return;
    }
    try {
      await platform.invokeMethod("launchUnity", {"uiName": uiName});
      debugPrint(" Unity launched with UI: $uiName");
    } on PlatformException catch (e) {
      debugPrint(" Failed to launch Unity: ${e.message}");
    }
  }

  //  Play tutorial video
  Future<void> _playTutorial(BuildContext context, String videoPath) async {
    final controller = VideoPlayerController.asset(videoPath);
    await controller.initialize();
    controller.play();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 38,
                        ),
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        },
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Close", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    await controller.dispose();
  }

  // Show the 4-option dialog
  void _openSubjectOptions(
    BuildContext context, {
    required String subjectName,
    required String uiName,
    required String tutorialPath,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E293B),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$subjectName Options",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                 _buildDialogButton(
                  icon: Icons.menu_book_outlined,
                  text: "Instructions",
                  color: Colors.tealAccent,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showInstructions(context, subjectName);
                  },
                ),
                  _buildDialogButton(
                  icon: Icons.play_circle_outline,
                  text: "Watch Tutorial",
                  color: Colors.greenAccent,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _playTutorial(context, tutorialPath);
                  },
                ),
                _buildDialogButton(
                  icon: Icons.science_outlined,
                  text: "Start Experiment",
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _launchUnityWithUI(uiName);
                  },
                ),
               
                _buildDialogButton(
                  icon: Icons.quiz_outlined,
                  text: "Take Quiz",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openQuiz(context, subjectName);
                  },
                ),
              
              ],
            ),
          ),
        );
      },
    );
  }

  //  Buttons inside dialog
  Widget _buildDialogButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black87),
        label: Text(
          text,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

 void _showInstructions(BuildContext context, String subject) {
  String instructions = "";

  if (subject == "Physics") {
    instructions =
        "🔬 Vernier Caliper Experiment\n\n"
        "1️⃣ Check zero error before measurement.\n"
        "2️⃣ Place the object between the jaws.\n"
        "3️⃣ Read main scale value.\n"
        "4️⃣ Add vernier scale reading.\n"
        "5️⃣ Record final measurement carefully.";
  } else if (subject == "Biology") {
    instructions =
        "🧫 Microscopic Bacteria Observation\n\n"
        "1️⃣ Prepare slide with sample.\n"
        "2️⃣ Place slide on microscope stage.\n"
        "3️⃣ Adjust coarse knob for focus.\n"
        "4️⃣ Use fine adjustment knob.\n"
        "5️⃣ Observe bacteria structure and note results.";
  } else if (subject == "Chemistry") {
    instructions =
        "🧲 Magnet, Sand & Iron Experiment\n\n"
        "1️⃣ Mix sand and iron filings.\n"
        "2️⃣ Bring magnet near mixture.\n"
        "3️⃣ Observe iron attracted to magnet.\n"
        "4️⃣ Separate collected iron.\n"
        "5️⃣ Record observation about magnetic property.";
  }

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text("Instructions - $subject",
            style: const TextStyle(color: Colors.white)),
        content: Text(
          instructions,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close",
                style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      );
    },
  );
}

  
 void _openQuiz(BuildContext context, String subject) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QuizScreen(subject: subject),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.school_outlined, color: Colors.white, size: 80),
                const SizedBox(height: 16),
                Text(
                  'Choose Your Subject ($className)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                 _buildSubjectButton(
                  title: "Biology",
                  icon: Icons.eco_outlined,
                  gradientColors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  onTap: () => _openSubjectOptions(
                    context,
                    subjectName: "Biology",
                    uiName: "UI_Canvas",
                    tutorialPath: "assets/video/bio.mp4",
                  ),
                ),
                 const SizedBox(height: 20),
                  _buildSubjectButton(
                  title: "Chemistry",
                  icon: Icons.biotech_outlined,
                  gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                  onTap: () => _openSubjectOptions(
                    context,
                    subjectName: "Chemistry",
                    uiName: "Ui_cmist",
                    tutorialPath: "assets/video/chmist.mp4",
                  ),
                ),
                const SizedBox(height: 20),
                _buildSubjectButton(
                  title: "Physics",
                  icon: Icons.science_outlined,
                  gradientColors: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  onTap: () => _openSubjectOptions(
                    context,
                    subjectName: "Physics",
                    uiName: "Ui_physi",
                    tutorialPath: "assets/video/physics.mp4",
                  ),
                ),
                
               
               
               
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Subject buttons 
  Widget _buildSubjectButton({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class QuizScreen extends StatefulWidget {
  final String subject;
  const QuizScreen({super.key, required this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;
  bool answered = false;

  late List<Map<String, dynamic>> questions;

  /// ⏳ Timer
  static const int questionTime = 15;
  int timeLeft = questionTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    questions = _getQuestions(widget.subject);
    _startTimer();
  }

  void _startTimer() {
    timeLeft = questionTime;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        _nextQuestion();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void _answerQuestion(int index) {
    if (answered) return;

    timer?.cancel();

    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == questions[currentQuestion]["answer"]) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    timer?.cancel();

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
      _startTimer();
    } else {
      _showResult();
    }
  }

  void _restartQuiz() {
    Navigator.pop(context);
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      answered = false;
    });
    _startTimer();
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events,
                  color: Colors.amber, size: 70),
              const SizedBox(height: 15),
              const Text(
                "Quiz Completed 🎉",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Your Score: $score / ${questions.length}",
                style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12)),
                ),
                onPressed: _restartQuiz,
                child: const Text("Restart Quiz"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("${widget.subject} Quiz"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔹 Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    (currentQuestion + 1) / questions.length,
                backgroundColor: Colors.white12,
                color: Colors.tealAccent,
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 15),

            /// 🔹 Timer
            Text(
              "Time Left: $timeLeft sec",
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16),
            ),

            const SizedBox(height: 20),

            /// 🔹 Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                question["question"],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

            /// 🔹 Options
            Expanded(
              child: ListView.builder(
                itemCount:
                    question["options"].length,
                itemBuilder: (context, index) {
                  Color borderColor =
                      Colors.tealAccent.withOpacity(0.4);

                  if (answered) {
                    if (index ==
                        question["answer"]) {
                      borderColor = Colors.green;
                    } else if (index ==
                        selectedAnswer) {
                      borderColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(15),
                      onTap: () =>
                          _answerQuestion(index),
                      child: Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1E293B),
                          borderRadius:
                              BorderRadius.circular(
                                  15),
                          border: Border.all(
                              color: borderColor,
                              width: 2),
                        ),
                        child: Text(
                          question["options"]
                              [index],
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 🔹 Next Button
            if (answered)
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.tealAccent,
                  foregroundColor:
                      Colors.black,
                  minimumSize: const Size(
                      double.infinity, 50),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),
                onPressed: _nextQuestion,
                child: const Text("Next"),
              )
          ],
        ),
      ),
    );
  }

  /// 🔹 Questions Data
  List<Map<String, dynamic>> _getQuestions(
      String subject) {
    if (subject == "Physics") {
      return [
        {
          "question":
              "What is Vernier Caliper used for?",
          "options": [
            "Measuring temperature",
            "Measuring length precisely",
            "Measuring weight",
            "Measuring time"
          ],
          "answer": 1
        },
        {
          "question":
              "Smallest count of Vernier Caliper is?",
          "options": [
            "0.1 cm",
            "0.01 cm",
            "1 cm",
            "10 cm"
          ],
          "answer": 1
        },
        {
          "question":
              "Which scale gives main reading?",
          "options": [
            "Vernier scale",
            "Main scale",
            "Meter scale",
            "Circular scale"
          ],
          "answer": 1
        },
        {
          "question":
              "Zero error must be?",
          "options": [
            "Ignored",
            "Added",
            "Subtracted/Added properly",
            "Multiplied"
          ],
          "answer": 2
        },
        {
          "question":
              "Vernier caliper measures?",
          "options": [
            "Diameter",
            "Depth",
            "Length",
            "All of these"
          ],
          "answer": 3
        },
      ];
    }

    if (subject == "Biology") {
      return [
        {
          "question":
              "Microscope is used to observe?",
          "options": [
            "Planets",
            "Cells",
            "Mountains",
            "Clouds"
          ],
          "answer": 1
        },
        {
          "question": "Bacteria are?",
          "options": [
            "Multicellular",
            "Unicellular",
            "Non-living",
            "Plants"
          ],
          "answer": 1
        },
        {
          "question":
              "Which knob gives fine focus?",
          "options": [
            "Coarse knob",
            "Fine adjustment knob",
            "Stage knob",
            "Mirror"
          ],
          "answer": 1
        },
        {
          "question":
              "Bacteria are seen under?",
          "options": [
            "Naked eye",
            "Microscope",
            "Telescope",
            "Scale"
          ],
          "answer": 1
        },
        {
          "question":
              "Slide is placed on?",
          "options": [
            "Lens",
            "Stage",
            "Mirror",
            "Base"
          ],
          "answer": 1
        },
      ];
    }

    return [
      {
        "question": "Magnet attracts?",
        "options": [
          "Sand",
          "Plastic",
          "Iron filings",
          "Paper"
        ],
        "answer": 2
      },
      {
        "question": "Iron is?",
        "options": [
          "Non-metal",
          "Metal",
          "Gas",
          "Liquid"
        ],
        "answer": 1
      },
      {
        "question":
            "Magnetic property belongs to?",
        "options": [
          "Iron",
          "Sand",
          "Water",
          "Wood"
        ],
        "answer": 0
      },
      {
        "question":
            "Magnet separates iron from?",
        "options": [
          "Water",
          "Sand",
          "Air",
          "Oil"
        ],
        "answer": 1
      },
      {
        "question":
            "Magnetic material is?",
        "options": [
          "Copper",
          "Iron",
          "Aluminum",
          "Plastic"
        ],
        "answer": 1
      },
    ];
  }
}