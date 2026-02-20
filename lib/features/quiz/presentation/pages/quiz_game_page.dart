import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/quiz_mock_data.dart';
import '../../domain/quiz_model.dart';

class QuizGamePage extends StatefulWidget {
  final int level;

  const QuizGamePage({super.key, required this.level});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage>
    with TickerProviderStateMixin {
  late List<QuizQuestion> questions;

  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;

  late AnimationController _questionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _generateRandomQuiz();

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeIn,
    );

    _questionController.forward();
  }

  void _generateRandomQuiz() {
    final allQuestions =
    List<QuizQuestion>.from(QuizMockData.getQuestions(widget.level));

    allQuestions.shuffle(Random());

    questions = allQuestions.map((q) {
      final answers = List<String>.from(q.answers);
      final correctAnswer = answers[q.correctIndex];

      answers.shuffle(Random());
      final newCorrectIndex = answers.indexOf(correctAnswer);

      return QuizQuestion(
        question: q.question,
        answers: answers,
        correctIndex: newCorrectIndex,
      );
    }).toList();
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      _questionController.reset();
      setState(() {
        currentIndex++;
        selectedIndex = null;
      });
      _questionController.forward();
    } else {
      _showResult();
    }
  }

  void _selectAnswer(int index) {
    if (selectedIndex != null) return;

    setState(() {
      selectedIndex = index;
      if (index == questions[currentIndex].correctIndex) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), _nextQuestion);
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bravo 🎉",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Score : $score / ${questions.length}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.pop(); // fermer dialog
                  context.pop(); // revenir au niveau
                },
                child: const Text("Retour"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// ⬅️ Retour propre
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 📈 Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      minHeight: 14,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                      const AlwaysStoppedAnimation(Colors.greenAccent),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: question.answers.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final isCorrect =
                            index == question.correctIndex;
                        final isSelected =
                            index == selectedIndex;

                        Color bgColor =
                        Colors.white.withOpacity(0.08);

                        if (selectedIndex != null) {
                          if (isCorrect) {
                            bgColor = Colors.green;
                          } else if (isSelected) {
                            bgColor = Colors.red;
                          }
                        }

                        return AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius:
                            BorderRadius.circular(20),
                            onTap: () =>
                                _selectAnswer(index),
                            child: Center(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(12),
                                child: Text(
                                  question.answers[index],
                                  textAlign: TextAlign.center,
                                  style:
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
