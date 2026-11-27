import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_theme.dart';
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
      final theme = PulseTheme.build(Theme.of(context).brightness);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Theme(
          data: theme,
          child: AlertDialog(
            icon: Icon(
              result.passed
                  ? Icons.emoji_events_outlined
                  : Icons.fact_check_outlined,
            ),
            title: Text(result.passed ? 'Bravo !' : 'Quiz terminé'),
            content: Text(
              'Score : ${result.correctAnswers} / ${result.totalQuestions} (${result.score} %)',
              textAlign: TextAlign.center,
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
      if (mounted) _back();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Résultat non enregistré. Réessayer.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    final questions = widget.quiz.questions;
    final question = questions.isEmpty ? null : questions[_currentIndex];
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          leading: BackButton(onPressed: _back),
        ),
        body: SafeArea(
          child: question == null
              ? const Center(
                  child: Text('Ce quiz ne contient aucune question.'),
                )
              : ListView(
                  padding: PulseTheme.pagePadding,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} sur ${questions.length}',
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / questions.length,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _controller,
                      child: Text(
                        question.text,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (
                      var index = 0;
                      index < question.choices.length;
                      index++
                    )
                      Card(
                        clipBehavior: Clip.antiAlias,
                        color: index == _selectedIndex
                            ? colors.primaryContainer
                            : colors.surface,
                        child: ListTile(
                          selected: index == _selectedIndex,
                          title: Text(question.choices[index].text),
                          trailing: index == _selectedIndex
                              ? const Icon(Icons.check_circle_outline)
                              : null,
                          onTap: _selectedIndex == null && !_submitting
                              ? () => _selectAnswer(index)
                              : null,
                        ),
                      ),
                    if (_error != null)
                      TextButton(onPressed: _submit, child: Text(_error!)),
                    if (_submitting)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
        ),
      ),
    );
  }
}
