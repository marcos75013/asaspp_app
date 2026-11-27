import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/member_quiz.dart';
import '../../data/member_quiz_api_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final MemberQuizApiService _api = MemberQuizApiService(
    ApiClient(AuthStorage()),
  );
  late Future<List<MemberQuiz>> _quizzes;

  @override
  void initState() {
    super.initState();
    _quizzes = _api.list();
  }

  void _reload() => setState(() => _quizzes = _api.list());

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    return Theme(
      data: theme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
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
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: colors.onSurface,
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
                        Text(
                          "Choisis un quiz",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    Expanded(
                      child: FutureBuilder<List<MemberQuiz>>(
                        future: _quizzes,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData && !snapshot.hasError) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: TextButton(
                                onPressed: _reload,
                                child: const Text(
                                  'Impossible de charger les quiz. Réessayer.',
                                ),
                              ),
                            );
                          }
                          final quizzes = snapshot.data ?? const <MemberQuiz>[];
                          if (quizzes.isEmpty) {
                            return const Center(
                              child: Text('Aucun quiz publié pour le moment.'),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              _reload();
                              await _quizzes;
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: quizzes.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 24),
                              itemBuilder: (context, index) =>
                                  _animatedQuizCard(
                                    context,
                                    quizzes[index],
                                    [
                                      Colors.green,
                                      Colors.orange,
                                      Colors.redAccent,
                                    ][index % 3],
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
      ),
    );
  }

  Widget _animatedQuizCard(BuildContext context, MemberQuiz quiz, Color color) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => context.push('/quiz/game', extra: quiz),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.85),
                    color.withValues(alpha: 0.55),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  quiz.title,
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
