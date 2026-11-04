import '../../../bo/bo_quiz.dart';
import '../../../bo/bo_widgets.dart' show boOpen;
import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Json> _quizzes = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await repositoryOf(context).list('/api/mobile/quizzes');
      if (mounted)
        setState(() {
          _quizzes = data;
          _loading = false;
          _error = null;
        });
    } catch (error) {
      if (mounted)
        setState(() {
          _error = readableError(error);
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌊 Background
          Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),

          /// 🌑 Overlay sombre
          Container(color: Colors.black.withOpacity(0.45)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// ⬅️ Flèche retour + titre centré
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                      ),
                      const Text(
                        "Choisis ton niveau",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => boOpen(context, const MemberQuizHistory()),
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text(
                      'Mes résultats',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_loading || _error != null || _quizzes.isEmpty)
                    DataStatus(
                      loading: _loading,
                      error: _error,
                      empty: 'Aucun quiz publié.',
                      reload: _load,
                    ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var index = 0; index < _quizzes.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _animatedLevelCard(
                              context,
                              _quizzes[index],
                              [
                                Colors.green,
                                Colors.orange,
                                Colors.redAccent,
                              ][index % 3],
                            ),
                          ),
                      ],
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

  Widget _animatedLevelCard(BuildContext context, Json quiz, Color color) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => context.push('/quiz/game', extra: quiz), // ✅ PUSH
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.85), color.withOpacity(0.55)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label(quiz, 'title'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
