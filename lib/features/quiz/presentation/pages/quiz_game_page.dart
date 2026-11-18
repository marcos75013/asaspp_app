import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/member_quiz.dart';
import '../../data/member_quiz_api_service.dart';

class QuizGamePage extends StatefulWidget {
  final MemberQuiz quiz;
  const QuizGamePage({super.key, required this.quiz});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage>
    with SingleTickerProviderStateMixin {
  late final MemberQuizApiService _api = MemberQuizApiService(
    ApiClient(AuthStorage()),
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();
  final Map<int, int> _answers = {};
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_selectedIndex != null || _submitting) return;
    final question = widget.quiz.questions[_currentIndex];
    _answers[question.index] = question.choices[index].index;
    setState(() {
      _selectedIndex = index;
      _error = null;
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_currentIndex < widget.quiz.questions.length - 1) {
        _controller.reset();
        setState(() {
          _currentIndex++;
          _selectedIndex = null;
        });
        _controller.forward();
      } else {
        _submit();
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _api.submit(widget.quiz, _answers);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
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
                Text(
                  result.passed ? 'Bravo 🎉' : 'Quiz terminé',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Score : ${result.correctAnswers} / ${result.totalQuestions} (${result.score} %)',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Résultat non enregistré. Réessayer.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ce quiz ne contient aucune question.')),
      );
    }
    final question = questions[_currentIndex];
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / questions.length,
                      minHeight: 14,
                      backgroundColor: Colors.white.withValues(alpha: .2),
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.greenAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _controller,
                    child: Text(
                      question.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_error != null)
                    TextButton(
                      onPressed: _submit,
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_submitting) const CircularProgressIndicator(),
                  const SizedBox(height: 40),
                  Expanded(
                    child: GridView.builder(
                      itemCount: question.choices.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final selected = index == _selectedIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.blueAccent
                                : Colors.white.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _selectAnswer(index),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  question.choices[index].text,
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
