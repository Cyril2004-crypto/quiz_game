import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TechQuizApp());
}

class TechQuizApp extends StatelessWidget {
  const TechQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Knowledge Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Virtual Identity Management
class UserProfile {
  final String username;
  final String avatar;
  final int totalScore;
  final int gamesPlayed;
  final List<String> achievements;
  final DateTime lastPlayed;

  UserProfile({
    required this.username,
    required this.avatar,
    required this.totalScore,
    required this.gamesPlayed,
    required this.achievements,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatar,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'achievements': achievements,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? 'Anonymous',
      avatar: json['avatar'] ?? '👤',
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      lastPlayed: DateTime.parse(json['lastPlayed'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Event-Driven Programming - Game Events
abstract class GameEvent {}

class GameStartEvent extends GameEvent {
  final String category;
  GameStartEvent(this.category);
}

class AnswerSelectedEvent extends GameEvent {
  final int questionIndex;
  final int selectedAnswer;
  AnswerSelectedEvent(this.questionIndex, this.selectedAnswer);
}

class GameEndEvent extends GameEvent {
  final int finalScore;
  final int totalQuestions;
  GameEndEvent(this.finalScore, this.totalQuestions);
}

// Event Handler
class GameEventHandler {
  final StreamController<GameEvent> _eventController = StreamController<GameEvent>.broadcast();
  
  Stream<GameEvent> get eventStream => _eventController.stream;
  
  void addEvent(GameEvent event) {
    _eventController.add(event);
  }
  
  void dispose() {
    _eventController.close();
  }
}

// Version Control - Quiz Data Management
class QuizVersion {
  final String version;
  final DateTime lastUpdated;
  final List<QuizQuestion> questions;
  final String changelog;

  QuizVersion({
    required this.version,
    required this.lastUpdated,
    required this.questions,
    required this.changelog,
  });
}

class QuizDataManager {
  static const String currentVersion = "3.1.0";
  static const int questionsPerQuiz = 15; // Number of questions per quiz attempt
  
  static List<QuizVersion> getVersionHistory() {
    return [
      QuizVersion(
        version: "1.0.0",
        lastUpdated: DateTime(2024, 1, 1),
        questions: _getBasicQuestions(),
        changelog: "Initial release with basic science questions",
      ),
      QuizVersion(
        version: "1.1.0",
        lastUpdated: DateTime(2024, 6, 1),
        questions: _getIntermediateQuestions(),
        changelog: "Added geography questions and expanded content",
      ),
      QuizVersion(
        version: "2.0.0",
        lastUpdated: DateTime(2024, 10, 2),
        questions: _getAllQuestions(),
        changelog: "Major update: Added general knowledge questions covering Science, Geography, Earth Science, and Politics & History",
      ),
      QuizVersion(
        version: "3.0.0",
        lastUpdated: DateTime(2024, 10, 2),
        questions: _getAllQuestions(),
        changelog: "Expanded content: Added Organic Chemistry, Inorganic Chemistry, Mathematics, and Physics questions",
      ),
      QuizVersion(
        version: "3.1.0",
        lastUpdated: DateTime(2024, 10, 2),
        questions: _getAllQuestions(),
        changelog: "Added dynamic question refresh: Each quiz attempt now presents a fresh selection of questions",
      ),
    ];
  }
  
  static List<QuizQuestion> getCurrentQuestions() {
    return getRandomQuestions();
  }
  
  /// Gets a random selection of questions for each quiz attempt
  static List<QuizQuestion> getRandomQuestions() {
    final allQuestions = _getAllQuestions();
    print('📚 Total questions available: ${allQuestions.length}');
    
    if (allQuestions.length <= questionsPerQuiz) {
      print('🔄 Using all available questions (${allQuestions.length})');
      final shuffled = List<QuizQuestion>.from(allQuestions);
      shuffled.shuffle();
      return shuffled;
    }
    
    // Ensure we get a balanced mix from different categories
    final Map<String, List<QuizQuestion>> questionsByCategory = {};
    
    // Group questions by category
    for (final question in allQuestions) {
      questionsByCategory.putIfAbsent(question.category, () => []).add(question);
    }
    
    print('📊 Categories available: ${questionsByCategory.keys.join(', ')}');
    
    // Calculate questions per category (roughly equal distribution)
    final categories = questionsByCategory.keys.toList();
    final questionsPerCategory = questionsPerQuiz ~/ categories.length;
    final extraQuestions = questionsPerQuiz % categories.length;
    
    print('🎯 Target: $questionsPerCategory questions per category (+$extraQuestions extra)');
    
    final selectedQuestions = <QuizQuestion>[];
    
    // Select questions from each category
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final categoryQuestions = List<QuizQuestion>.from(questionsByCategory[category]!);
      categoryQuestions.shuffle();
      
      // Determine how many questions to take from this category
      int questionsToTake = questionsPerCategory;
      if (i < extraQuestions) {
        questionsToTake++; // Distribute extra questions to first few categories
      }
      
      // Take the determined number of questions from this category
      final questionsFromCategory = categoryQuestions.take(questionsToTake).toList();
      selectedQuestions.addAll(questionsFromCategory);
      
      print('📝 Selected ${questionsFromCategory.length} questions from $category');
    }
    
    // Final shuffle to mix categories
    selectedQuestions.shuffle();
    
    print('✅ Final quiz: ${selectedQuestions.length} questions selected');
    print('🔀 Categories in quiz: ${selectedQuestions.map((q) => q.category).toSet().join(', ')}');
    
    return selectedQuestions;
  }
  
  /// Gets all available questions (full pool)
  static List<QuizQuestion> getAllAvailableQuestions() {
    return _getAllQuestions();
  }
  
  static List<QuizQuestion> _getBasicQuestions() {
    return [
      QuizQuestion(
        question: "What is the largest planet in our solar system?",
        options: ["Earth", "Jupiter", "Saturn", "Neptune"],
        correctAnswer: 1,
        category: "Science",
        explanation: "Jupiter is the largest planet in our solar system, with a mass greater than all other planets combined.",
      ),
    ];
  }
  
  static List<QuizQuestion> _getIntermediateQuestions() {
    return [
      ..._getBasicQuestions(),
      QuizQuestion(
        question: "What is the capital of Australia?",
        options: ["Sydney", "Canberra", "Melbourne", "Perth"],
        correctAnswer: 1,
        category: "Geography",
        explanation: "Canberra is the capital city of Australia, located in the Australian Capital Territory.",
      ),
    ];
  }
  
  static List<QuizQuestion> _getAllQuestions() {
    return [
      // Science Questions
      QuizQuestion(
        question: "What is the chemical symbol for gold?",
        options: ["Go", "Au", "Ag", "Gd"],
        correctAnswer: 1,
        category: "Science",
        explanation: "Au is the chemical symbol for gold, derived from the Latin word 'aurum'.",
      ),
      QuizQuestion(
        question: "What is the speed of light in vacuum?",
        options: ["300,000 km/s", "299,792,458 m/s", "186,000 miles/s", "All of the above"],
        correctAnswer: 3,
        category: "Science",
        explanation: "The speed of light in vacuum is approximately 299,792,458 meters per second, which equals about 300,000 km/s or 186,000 miles/s.",
      ),
      QuizQuestion(
        question: "Which organ in the human body produces insulin?",
        options: ["Liver", "Pancreas", "Kidney", "Heart"],
        correctAnswer: 1,
        category: "Science",
        explanation: "The pancreas produces insulin, a hormone that regulates blood sugar levels.",
      ),
      
      // Organic Chemistry Questions
      QuizQuestion(
        question: "What is the functional group present in alcohols?",
        options: ["-COOH", "-OH", "-CHO", "-CO-"],
        correctAnswer: 1,
        category: "Organic Chemistry",
        explanation: "The hydroxyl group (-OH) is the functional group that defines alcohols.",
      ),
      QuizQuestion(
        question: "Which of the following is the simplest alkene?",
        options: ["Methane", "Ethene", "Propene", "Butene"],
        correctAnswer: 1,
        category: "Organic Chemistry",
        explanation: "Ethene (C₂H₄) is the simplest alkene, containing a carbon-carbon double bond.",
      ),
      QuizQuestion(
        question: "What type of reaction is used to convert alkenes to alkanes?",
        options: ["Oxidation", "Reduction", "Substitution", "Elimination"],
        correctAnswer: 1,
        category: "Organic Chemistry",
        explanation: "Reduction reactions (like hydrogenation) convert alkenes to alkanes by adding hydrogen across the double bond.",
      ),
      QuizQuestion(
        question: "Which compound has the molecular formula C₆H₆?",
        options: ["Cyclohexane", "Benzene", "Hexane", "Toluene"],
        correctAnswer: 1,
        category: "Organic Chemistry",
        explanation: "Benzene (C₆H₆) is an aromatic compound with a ring of six carbon atoms.",
      ),
      
      // Inorganic Chemistry Questions
      QuizQuestion(
        question: "What is the oxidation state of chromium in K₂Cr₂O₇?",
        options: ["+3", "+6", "+2", "+7"],
        correctAnswer: 1,
        category: "Inorganic Chemistry",
        explanation: "In potassium dichromate (K₂Cr₂O₇), chromium has an oxidation state of +6.",
      ),
      QuizQuestion(
        question: "Which acid is known as the 'king of chemicals'?",
        options: ["Hydrochloric acid", "Nitric acid", "Sulfuric acid", "Phosphoric acid"],
        correctAnswer: 2,
        category: "Inorganic Chemistry",
        explanation: "Sulfuric acid (H₂SO₄) is called the 'king of chemicals' due to its widespread industrial use.",
      ),
      QuizQuestion(
        question: "What is the coordination number of the central atom in [Cu(NH₃)₄]²⁺?",
        options: ["2", "4", "6", "8"],
        correctAnswer: 1,
        category: "Inorganic Chemistry",
        explanation: "In the tetraamminecopper(II) ion, copper has a coordination number of 4.",
      ),
      QuizQuestion(
        question: "Which noble gas has the highest boiling point?",
        options: ["Helium", "Neon", "Argon", "Radon"],
        correctAnswer: 3,
        category: "Inorganic Chemistry",
        explanation: "Radon has the highest boiling point among noble gases due to stronger van der Waals forces.",
      ),
      
      // Mathematics Questions
      QuizQuestion(
        question: "What is the derivative of sin(x)?",
        options: ["cos(x)", "-cos(x)", "sin(x)", "-sin(x)"],
        correctAnswer: 0,
        category: "Mathematics",
        explanation: "The derivative of sin(x) with respect to x is cos(x).",
      ),
      QuizQuestion(
        question: "What is the value of π (pi) to 3 decimal places?",
        options: ["3.141", "3.142", "3.143", "3.144"],
        correctAnswer: 1,
        category: "Mathematics",
        explanation: "π (pi) is approximately 3.142 when rounded to 3 decimal places.",
      ),
      QuizQuestion(
        question: "What is the sum of angles in a triangle?",
        options: ["90°", "180°", "270°", "360°"],
        correctAnswer: 1,
        category: "Mathematics",
        explanation: "The sum of all interior angles in any triangle is always 180 degrees.",
      ),
      QuizQuestion(
        question: "What is the quadratic formula?",
        options: ["x = -b ± √(b²-4ac)/2a", "x = b ± √(b²+4ac)/2a", "x = -b ± √(b²+4ac)/2a", "x = b ± √(b²-4ac)/2a"],
        correctAnswer: 0,
        category: "Mathematics",
        explanation: "The quadratic formula is x = (-b ± √(b²-4ac))/2a for solving ax² + bx + c = 0.",
      ),
      QuizQuestion(
        question: "What is the integral of 1/x?",
        options: ["ln(x) + C", "x + C", "1/x² + C", "e^x + C"],
        correctAnswer: 0,
        category: "Mathematics",
        explanation: "The integral of 1/x is ln|x| + C, where C is the constant of integration.",
      ),
      
      // Physics Questions
      QuizQuestion(
        question: "What is Newton's second law of motion?",
        options: ["F = ma", "E = mc²", "v = u + at", "F = mg"],
        correctAnswer: 0,
        category: "Physics",
        explanation: "Newton's second law states that Force equals mass times acceleration (F = ma).",
      ),
      QuizQuestion(
        question: "What is the unit of electric current?",
        options: ["Volt", "Ampere", "Ohm", "Watt"],
        correctAnswer: 1,
        category: "Physics",
        explanation: "The ampere (A) is the SI unit of electric current.",
      ),
      QuizQuestion(
        question: "What is the acceleration due to gravity on Earth?",
        options: ["9.8 m/s²", "10 m/s²", "8.9 m/s²", "11 m/s²"],
        correctAnswer: 0,
        category: "Physics",
        explanation: "The acceleration due to gravity on Earth is approximately 9.8 m/s².",
      ),
      QuizQuestion(
        question: "Which physicist proposed the theory of relativity?",
        options: ["Newton", "Einstein", "Galileo", "Planck"],
        correctAnswer: 1,
        category: "Physics",
        explanation: "Albert Einstein proposed both the special and general theories of relativity.",
      ),
      QuizQuestion(
        question: "What is the formula for kinetic energy?",
        options: ["KE = mgh", "KE = ½mv²", "KE = mc²", "KE = Fd"],
        correctAnswer: 1,
        category: "Physics",
        explanation: "Kinetic energy is given by KE = ½mv², where m is mass and v is velocity.",
      ),
      
      // Geography Questions
      QuizQuestion(
        question: "Which is the longest river in the world?",
        options: ["Amazon River", "Nile River", "Yangtze River", "Mississippi River"],
        correctAnswer: 1,
        category: "Geography",
        explanation: "The Nile River is traditionally considered the longest river in the world at approximately 6,650 kilometers.",
      ),
      QuizQuestion(
        question: "What is the smallest country in the world?",
        options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"],
        correctAnswer: 1,
        category: "Geography",
        explanation: "Vatican City is the smallest country in the world with an area of just 0.17 square miles.",
      ),
      QuizQuestion(
        question: "Which mountain range contains Mount Everest?",
        options: ["Andes", "Himalayas", "Rocky Mountains", "Alps"],
        correctAnswer: 1,
        category: "Geography",
        explanation: "Mount Everest is located in the Himalayas on the border between Nepal and Tibet.",
      ),
      
      // Earth Science Questions
      QuizQuestion(
        question: "What causes earthquakes?",
        options: ["Ocean tides", "Tectonic plate movement", "Weather changes", "Magnetic fields"],
        correctAnswer: 1,
        category: "Earth Science",
        explanation: "Earthquakes are primarily caused by the movement of tectonic plates beneath the Earth's surface.",
      ),
      QuizQuestion(
        question: "What is the Earth's outermost layer called?",
        options: ["Mantle", "Crust", "Core", "Atmosphere"],
        correctAnswer: 1,
        category: "Earth Science",
        explanation: "The crust is the Earth's outermost solid layer, where we live and where most geological activity occurs.",
      ),
      QuizQuestion(
        question: "What type of rock is formed by volcanic activity?",
        options: ["Sedimentary", "Igneous", "Metamorphic", "Composite"],
        correctAnswer: 1,
        category: "Earth Science",
        explanation: "Igneous rocks are formed when molten rock (magma or lava) cools and solidifies.",
      ),
      
      // Politics & History Questions
      QuizQuestion(
        question: "Who was the first President of the United States?",
        options: ["Thomas Jefferson", "George Washington", "John Adams", "Benjamin Franklin"],
        correctAnswer: 1,
        category: "Politics & History",
        explanation: "George Washington was the first President of the United States, serving from 1789 to 1797.",
      ),
      QuizQuestion(
        question: "In which year did World War II end?",
        options: ["1944", "1945", "1946", "1947"],
        correctAnswer: 1,
        category: "Politics & History",
        explanation: "World War II ended in 1945 with the surrender of Japan in September following the atomic bombings.",
      ),
      QuizQuestion(
        question: "What is the United Nations headquarters located?",
        options: ["Geneva", "New York City", "London", "Paris"],
        correctAnswer: 1,
        category: "Politics & History",
        explanation: "The United Nations headquarters is located in New York City, United States.",
      ),
      
      // Additional Science Questions
      QuizQuestion(
        question: "What gas do plants absorb from the atmosphere during photosynthesis?",
        options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"],
        correctAnswer: 1,
        category: "Science",
        explanation: "Plants absorb carbon dioxide from the atmosphere and convert it into glucose during photosynthesis.",
      ),
      QuizQuestion(
        question: "What is the hardest natural substance on Earth?",
        options: ["Iron", "Diamond", "Quartz", "Granite"],
        correctAnswer: 1,
        category: "Science",
        explanation: "Diamond is the hardest natural substance on Earth, rating 10 on the Mohs hardness scale.",
      ),
      QuizQuestion(
        question: "How many chambers does a human heart have?",
        options: ["Two", "Four", "Six", "Eight"],
        correctAnswer: 1,
        category: "Science",
        explanation: "The human heart has four chambers: two atria and two ventricles.",
      ),
    ];
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.explanation,
  });
}

// Welcome Screen with Virtual Identity Setup
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedAvatar = '👤';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _avatars = ['👤', '👨‍💻', '👩‍💻', '🧑‍🔬', '👨‍🎓', '👩‍🎓', '🤖', '👾'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('userProfile');
    if (profileJson != null) {
      final profile = UserProfile.fromJson(jsonDecode(profileJson));
      _usernameController.text = profile.username;
      setState(() {
        _selectedAvatar = profile.avatar;
      });
    }
  }

  void _startQuiz() async {
    print('🔥 START QUIZ BUTTON PRESSED!'); // Enhanced debug
    print('Start Quiz button clicked'); // Debug
    if (_usernameController.text.trim().isEmpty) {
      print('❌ Username is empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username')),
      );
      return;
    }

    print('Creating user profile...'); // Debug
    // Save user profile
    final profile = UserProfile(
      username: _usernameController.text.trim(),
      avatar: _selectedAvatar,
      totalScore: 0,
      gamesPlayed: 0,
      achievements: [],
      lastPlayed: DateTime.now(),
    );
    
    print('Saving profile to SharedPreferences...'); // Debug
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(profile.toJson()));

    // Test questions loading with refresh info
    print('🔄 Generating fresh question set...');
    final totalQuestions = QuizDataManager.getAllAvailableQuestions().length;
    final quizQuestions = QuizDataManager.getCurrentQuestions();
    print('📚 Total questions in pool: $totalQuestions');
    print('🎯 Questions for this quiz: ${quizQuestions.length}');
    if (quizQuestions.isNotEmpty) {
      print('📝 First question: ${quizQuestions.first.question}');
      print('🏷️ First question category: ${quizQuestions.first.category}');
    }

    print('Navigating to QuizScreen...'); // Debug
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(userProfile: profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.quiz,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'General Knowledge Quiz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Test your knowledge with fresh questions every time!\n\n📚 Question Pool: 33+ questions\n🎯 Per Quiz: 15 random questions\n\nCategories:\n• Science & Biology\n• Organic Chemistry\n• Inorganic Chemistry\n• Mathematics\n• Physics\n• Geography & World Facts\n• Earth Science & Environment\n• Politics & History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Create Your Virtual Identity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Choose your avatar:'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: _avatars.map((avatar) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatar = avatar;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedAvatar == avatar 
                                          ? Colors.indigo 
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    avatar,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      print('🔥 START QUIZ BUTTON PRESSED!'); // Enhanced debug
                      _startQuiz();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Start Quiz'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Test Screen to debug navigation
class TestScreen extends StatelessWidget {
  final UserProfile userProfile;

  const TestScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen - ${userProfile.username}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Navigation works!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('User: ${userProfile.avatar} ${userProfile.username}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(userProfile: userProfile),
                  ),
                );
              },
              child: Text('Go to Quiz'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// Main Quiz Screen with Event-Driven Programming
class QuizScreen extends StatefulWidget {
  final UserProfile userProfile;

  const QuizScreen({super.key, required this.userProfile});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  late Timer _timer;
  int _timeRemaining = 30;
  final GameEventHandler _eventHandler = GameEventHandler();
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    print('QuizScreen initState called'); // Debug
    _questions = QuizDataManager.getCurrentQuestions();
    print('Questions loaded: ${_questions.length}'); // Debug
    print('🔄 Fresh question set generated for this attempt!');
    
    // Log the categories in this quiz attempt
    final categories = _questions.map((q) => q.category).toSet();
    print('📚 Categories in this quiz: ${categories.join(', ')}');
    
    // Don't shuffle again since getCurrentQuestions() already provides a randomized set
    _startTimer();
    _setupEventListeners();
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_progressAnimationController);
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _eventHandler.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _setupEventListeners() {
    _eventHandler.eventStream.listen((event) {
      if (event is GameStartEvent) {
        print('Game started with category: ${event.category}');
      } else if (event is AnswerSelectedEvent) {
        print('Answer selected: ${event.selectedAnswer} for question ${event.questionIndex}');
      } else if (event is GameEndEvent) {
        print('Game ended with score: ${event.finalScore}/${event.totalQuestions}');
      }
    });
    
    // Trigger game start event
    _eventHandler.addEvent(GameStartEvent('Mixed Categories'));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _nextQuestion();
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;
    
    setState(() {
      _selectedAnswer = index;
      _showExplanation = true;
    });
    
    // Trigger answer selected event
    _eventHandler.addEvent(AnswerSelectedEvent(_currentQuestionIndex, index));
    
    if (index == _questions[_currentQuestionIndex].correctAnswer) {
      _score++;
    }
    
    _timer.cancel();
    
    // Auto-advance after showing explanation
    Timer(const Duration(seconds: 3), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
        _timeRemaining = 30;
        _progressAnimationController.reset();
        _progressAnimationController.forward();
        _startTimer();
      } else {
        _endQuiz();
      }
    });
  }

  void _endQuiz() {
    _timer.cancel();
    _eventHandler.addEvent(GameEndEvent(_score, _questions.length));
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: _score,
          totalQuestions: _questions.length,
          userProfile: widget.userProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userProfile.avatar} ${widget.userProfile.username}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Fresh',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$_score/${_questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: progress * _progressAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Question Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timeRemaining <= 10 ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_timeRemaining s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.indigo),
              ),
              child: Text(
                question.category,
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Answer Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  Color? backgroundColor;
                  Color? textColor;
                  
                  if (_selectedAnswer != null) {
                    if (index == question.correctAnswer) {
                      backgroundColor = Colors.green;
                      textColor = Colors.white;
                    } else if (index == _selectedAnswer) {
                      backgroundColor = Colors.red;
                      textColor = Colors.white;
                    }
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null ? () => _selectAnswer(index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        '${String.fromCharCode(65 + index)}. ${question.options[index]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Explanation
            if (_showExplanation)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explanation:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(question.explanation),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Results Screen with Interoperability Features
class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final UserProfile userProfile;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.userProfile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  List<String> _newAchievements = [];

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.score.toDouble())
        .animate(CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeInOut));
    
    _scoreAnimationController.forward();
    _updateUserProfile();
    _checkAchievements();
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() async {
    final updatedProfile = UserProfile(
      username: widget.userProfile.username,
      avatar: widget.userProfile.avatar,
      totalScore: widget.userProfile.totalScore + widget.score,
      gamesPlayed: widget.userProfile.gamesPlayed + 1,
      achievements: [...widget.userProfile.achievements, ..._newAchievements],
      lastPlayed: DateTime.now(),
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(updatedProfile.toJson()));
  }

  void _checkAchievements() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    
    if (percentage == 100 && !widget.userProfile.achievements.contains('Perfect Score')) {
      _newAchievements.add('Perfect Score');
    }
    if (percentage >= 80 && !widget.userProfile.achievements.contains('Tech Expert')) {
      _newAchievements.add('Tech Expert');
    }
    if (widget.userProfile.gamesPlayed + 1 >= 5 && !widget.userProfile.achievements.contains('Quiz Master')) {
      _newAchievements.add('Quiz Master');
    }
  }

  String _getPerformanceMessage() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    
    if (percentage >= 90) return "Outstanding! You're a knowledge expert! 🎉\nTry again for a fresh set of questions!";
    if (percentage >= 80) return "Excellent work! Great knowledge! 👏\nReady for another challenge?";
    if (percentage >= 70) return "Good job! Keep learning! 📚\nEach new attempt brings different questions!";
    if (percentage >= 50) return "Not bad! Room for improvement! 💪\nTry again with fresh questions!";
    return "Keep studying! You'll get better! 🚀\nNew questions await your next attempt!";
  }

  void _shareResults() {
    // Simulating interoperability - sharing results to external platforms
    final resultText = '''
🎯 Tech Quiz Results 🎯
Player: ${widget.userProfile.avatar} ${widget.userProfile.username}
Score: ${widget.score}/${widget.totalQuestions} (${((widget.score / widget.totalQuestions) * 100).round()}%)
Categories: Version Control, Event-Driven Programming, Interoperability, Virtual Identity

${_getPerformanceMessage()}

#TechQuiz #Programming #Learning
    ''';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Results ready to share:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                resultText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Results copied to clipboard! (Simulated)')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _viewVersionHistory() {
    final versions = QuizDataManager.getVersionHistory();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Version History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              final isCurrentVersion = version.version == QuizDataManager.currentVersion;
              
              return Card(
                color: isCurrentVersion ? Colors.indigo.shade50 : null,
                child: ListTile(
                  leading: Icon(
                    isCurrentVersion ? Icons.star : Icons.history,
                    color: isCurrentVersion ? Colors.indigo : Colors.grey,
                  ),
                  title: Text(
                    'Version ${version.version}',
                    style: TextStyle(
                      fontWeight: isCurrentVersion ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${version.lastUpdated.toString().split(' ')[0]}\n${version.changelog}',
                  ),
                  trailing: isCurrentVersion 
                      ? const Chip(
                          label: Text('Current'),
                          backgroundColor: Colors.indigo,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.yellow,
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.userProfile.avatar} ${widget.userProfile.username}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quiz Complete!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Animated Score Display
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              '${_scoreAnimation.value.round()}/${widget.totalQuestions}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            Text(
                              '${percentage.round()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getPerformanceMessage(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // New Achievements
                if (_newAchievements.isNotEmpty) ...[
                  const Text(
                    'New Achievements! 🏆',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _newAchievements.map((achievement) {
                      return Chip(
                        label: Text(achievement),
                        backgroundColor: Colors.yellow,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Action Buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Fresh Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _shareResults,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _viewVersionHistory,
                      icon: const Icon(Icons.history),
                      label: const Text('Versions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
