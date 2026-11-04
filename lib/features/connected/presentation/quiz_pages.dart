import 'package:flutter/material.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'collection_page.dart';

class ConnectedQuizzes extends StatelessWidget {
  final ClubApi api;
  const ConnectedQuizzes({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/mobile/quizzes',
    title: 'Quiz',
    subtitle: 'Testez vos connaissances et retrouvez vos résultats.',
    action: FloatingActionButton.extended(
      onPressed: () => openPage(context, QuizHistory(api: api)),
      icon: const Icon(Icons.history),
      label: const Text('Mes résultats'),
    ),
    itemBuilder: (context, quiz, refresh) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Tag('${(quiz['questions'] as List).length} questions'),
            ),
            const SizedBox(height: 14),
            Text(
              label(quiz, 'title'),
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(label(quiz, 'description')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: (quiz['questions'] as List).isEmpty
                  ? null
                  : () => openPage(context, QuizRun(api: api, quiz: quiz)),
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    ),
  );
}

class QuizHistory extends StatelessWidget {
  final ClubApi api;
  const QuizHistory({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/mobile/quizzes/history',
    title: 'Mes résultats',
    subtitle: 'Chaque tentative est un pas de plus.',
    emptyMessage:
        'Vos résultats seront enregistrés ici après votre premier quiz.',
    itemBuilder: (context, item, refresh) => Card(
      child: ListTile(
        leading: Icon(
          item['passed'] == true
              ? Icons.verified_outlined
              : Icons.school_outlined,
          color: teal,
        ),
        title: Text(label(item, 'quizTitle')),
        subtitle: Text(dateLabel(item['submittedAt'])),
        trailing: Text(
          '${item['score']} %',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

class QuizRun extends StatefulWidget {
  final ClubApi api;
  final Json quiz;
  const QuizRun({super.key, required this.api, required this.quiz});
  @override
  State<QuizRun> createState() => _QuizRunState();
}

class _QuizRunState extends State<QuizRun> {
  late final List<Json> _questions = records(widget.quiz['questions']);
  final Map<int, int> _answers = {};
  int _step = 0;
  bool _busy = false;
  Json? _result;
  Future<void> _submit() async {
    setState(() => _busy = true);
    await runAction(context, () async {
      final response = await widget.api.request(
        '/api/mobile/quizzes/${widget.quiz['id']}/attempts',
        method: 'POST',
        data: {
          'answers': _answers.entries
              .map(
                (entry) => {
                  'questionIndex': entry.key,
                  'choiceIndex': entry.value,
                },
              )
              .toList(),
        },
      );
      if (mounted) {
        setState(() => _result = Map<String, dynamic>.from(response as Map));
      }
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_step];
    final id = question['index'] as int;
    return Scaffold(
      appBar: AppBar(title: Text(label(widget.quiz, 'title'))),
      body: PageBody(
        children: _result != null
            ? [
                Heading(
                  _result!['passed'] == true
                      ? 'Bien joué !'
                      : 'Vous progressez.',
                  'Votre résultat a été enregistré.',
                ),
                Text(
                  '${_result!['score']} %',
                  style: const TextStyle(
                    fontSize: 72,
                    color: teal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_result!['correctAnswers']} bonnes réponses sur ${_result!['totalQuestions']}',
                ),
                const SizedBox(height: 24),
                ...records(_result!['corrections']).map((correction) {
                  final q = _questions.firstWhere(
                    (q) => q['index'] == correction['questionIndex'],
                  );
                  final choice = records(q['choices']).firstWhere(
                    (c) => c['index'] == correction['correctChoiceIndex'],
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            correction['correct'] == true
                                ? Icons.check_circle_outline
                                : Icons.lightbulb_outline,
                            color: teal,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label(q, 'text'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text('Bonne réponse : ${label(choice, 'text')}'),
                          if (label(correction, 'explanation').isNotEmpty)
                            Text(label(correction, 'explanation')),
                        ],
                      ),
                    ),
                  );
                }),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terminer'),
                ),
              ]
            : [
                Heading(
                  'Quiz',
                  'Question ${_step + 1} sur ${_questions.length}',
                ),
                LinearProgressIndicator(
                  value: (_step + 1) / _questions.length,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 30),
                Text(
                  label(question, 'text'),
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                ...records(question['choices']).map((choice) {
                  final selected = _answers[id] == choice['index'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected ? mint : Colors.white,
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: _busy
                          ? null
                          : () => setState(
                              () => _answers[id] = choice['index'] as int,
                            ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(label(choice, 'text'))),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy || !_answers.containsKey(id)
                      ? null
                      : () => _step + 1 == _questions.length
                            ? _submit()
                            : setState(() => _step++),
                  child: Text(
                    _busy
                        ? 'Enregistrement…'
                        : _step + 1 == _questions.length
                        ? 'Voir mon résultat'
                        : 'Continuer',
                  ),
                ),
                if (_step > 0)
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _step--),
                    child: const Text('Question précédente'),
                  ),
              ],
      ),
    );
  }
}
