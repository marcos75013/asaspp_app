import '../../../bo/bo_widgets.dart' show boOpen, BoCard;
import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/quiz_model.dart';

class QuizGamePage extends StatefulWidget {
  final Json quiz;

  const QuizGamePage({super.key, required this.quiz});

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

    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _questionController, curve: Curves.easeOut),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeIn,
    );

    _questionController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionController.dispose();
    super.dispose();
  }

  final List<Json> _answers = [];
  Timer? _timer;
  bool _submitting = false;
  Json? _result;
  void _generateRandomQuiz() {
    questions = records(widget.quiz['questions'])
        .map(
          (q) => QuizQuestion(
            question: label(q, 'text'),
            answers: records(
              q['choices'],
            ).map((c) => label(c, 'text')).toList(),
            correctIndex: -1,
          ),
        )
        .toList();
  }

  void _nextQuestion() {
    if (!mounted) return;
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
      final question = records(widget.quiz['questions'])[currentIndex];
      final choice = records(question['choices'])[index];
      _answers.add({
        'questionIndex': question['index'],
        'choiceIndex': choice['index'],
      });
    });

    _timer = Timer(const Duration(milliseconds: 900), _nextQuestion);
  }

  Future<void> _showResult() async {
    if (_submitting) return;
    _submitting = true;
    try {
      if (_result == null) {
        final api = await repositoryOf(context).api();
        _result = Map<String, dynamic>.from(
          await api.request(
            '/api/mobile/quizzes/${widget.quiz['id']}/attempts',
            method: 'POST',
            data: {'answers': _answers},
          ),
        );
      }
      score = _result!['correctAnswers'] as int;
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(readableError(error)),
            action: SnackBarAction(label: 'Réessayer', onPressed: _showResult),
          ),
        );
      _submitting = false;
      return;
    }
    _submitting = false;
    if (!mounted) return;
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
                'Résultat enregistré',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Score : $score / ${questions.length}",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => boOpen(
                  context,
                  Scaffold(
                    appBar: AppBar(title: const Text('Correction du quiz')),
                    body: ListView(
                      padding: const EdgeInsets.all(20),
                      children: records(_result!['corrections']).map((
                        correction,
                      ) {
                        final question = records(widget.quiz['questions'])
                            .where(
                              (q) => q['index'] == correction['questionIndex'],
                            )
                            .firstOrNull;
                        final answer = records(question?['choices'])
                            .where(
                              (c) =>
                                  c['index'] ==
                                  correction['correctChoiceIndex'],
                            )
                            .firstOrNull;
                        return BoCard(
                          title: label(question ?? {}, 'text', 'Question'),
                          subtitle:
                              '${correction['correct'] == true ? 'Bonne réponse' : 'À revoir'}\nRéponse attendue : ${label(answer ?? {}, 'text')}\n${label(correction, 'explanation')}',
                        );
                      }).toList(),
                    ),
                  ),
                ),
                child: const Text(
                  'Voir la correction',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop(); // fermer dialog
                  context.pop(); // revenir au niveau
                },
                child: const Text("Retour"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty)
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ce quiz ne contient aucune question.')),
      );
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
                  Color(0xFF2C5364),
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
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
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
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.greenAccent,
                      ),
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
                        final isSelected = index == selectedIndex;

                        Color bgColor = Colors.white.withOpacity(0.08);

                        if (isSelected) bgColor = Colors.blueAccent;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _selectAnswer(index),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  question.answers[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
