import 'package:flutter/material.dart';
import 'bo_widgets.dart';

class BoQuizzes extends StatelessWidget {
  const BoQuizzes({super.key});
  Future<void> _edit(
    BuildContext context,
    ClubApi api,
    Future<void> Function() reload, [
    Json? quiz,
  ]) async {
    if (await boOpen<bool>(context, BoQuizEditor(api: api, quiz: quiz)) == true)
      await reload();
  }

  @override
  Widget build(BuildContext context) => BoList(
    title: 'Gestion des quiz',
    load: (a) => a.list('/api/quizzes', query: {'includeDrafts': true}),
    add: (c, a, r) => _edit(c, a, r),
    tile: (c, a, q, r) => BoCard(
      title: label(q, 'title'),
      subtitle:
          '${q['published'] == true ? 'Publié' : 'Brouillon'} · ${records(q['questions']).length} question(s)\nSeuil : ${q['passingScore']} %',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () => _edit(c, a, r, q)),
            BoAction('Résultats des membres', () async {
              await boOpen(
                c,
                BoList(
                  title: 'Résultats · ${label(q, 'title')}',
                  load: (api) => api.list('/api/quizzes/${q['id']}/attempts'),
                  tile: (context, api, result, reload) => BoCard(
                    title: person(result),
                    subtitle:
                        '${label(result, 'email')}\n${result['score']} % · ${result['passed'] == true ? 'Réussi' : 'À retravailler'}\n${label(result, 'submittedAt').replaceAll('T', ' ')}',
                  ),
                ),
              );
            }),
            BoAction(
              'Supprimer',
              () => boDelete(c, a, '/api/quizzes/${q['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoQuizEditor extends StatefulWidget {
  final ClubApi api;
  final Json? quiz;
  const BoQuizEditor({super.key, required this.api, this.quiz});
  @override
  State<BoQuizEditor> createState() => _BoQuizEditorState();
}

class _BoQuizEditorState extends State<BoQuizEditor> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.quiz?['title']);
  late final _description = TextEditingController(
    text: widget.quiz?['description'],
  );
  late final _passing = TextEditingController(
    text: '${widget.quiz?['passingScore'] ?? 80}',
  );
  late bool _published = widget.quiz?['published'] == true;
  late final List<Json> _questions = records(
    widget.quiz?['questions'],
  ).map((q) => Map<String, dynamic>.from(q)).toList();
  bool _busy = false;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _passing.dispose();
    super.dispose();
  }

  Future<void> _editQuestion([int? index]) async {
    final q = index == null ? <String, dynamic>{} : _questions[index];
    final options = records(q['choices']);
    final initial = <String, dynamic>{
      'text': q['text'],
      'explanation': q['explanation'],
      for (int i = 0; i < options.length; i++) ...{
        'choice$i': options[i]['text'],
        'correct$i': options[i]['correct'],
      },
    };
    Json? result;
    final ok = await boOpen<bool>(
      context,
      BoForm(
        title: 'Question',
        initial: initial,
        help:
            'Renseignez de 2 à 6 réponses et cochez au moins une bonne réponse.',
        fields: [
          const BoField('text', 'Question', required: true, kind: 'multiline'),
          const BoField(
            'explanation',
            'Explication de la correction',
            kind: 'multiline',
          ),
          for (int i = 0; i < 6; i++) ...[
            BoField('choice$i', 'Réponse ${i + 1}', required: i < 2),
            BoField('correct$i', 'Réponse ${i + 1} correcte', kind: 'bool'),
          ],
        ],
        validate: (v) {
          if (!List.generate(
            6,
            (i) => i,
          ).any((i) => v['correct$i'] == true && v['choice$i'] != null))
            return 'Indiquez au moins une bonne réponse.';
          return null;
        },
        save: (v) async {
          result = {
            'text': v['text'],
            'explanation': v['explanation'] ?? '',
            'choices': [
              for (int i = 0; i < 6; i++)
                if (v['choice$i'] != null)
                  {'text': v['choice$i'], 'correct': v['correct$i'] == true},
            ],
          };
        },
      ),
    );
    if (ok == true && mounted)
      setState(() {
        if (index == null)
          _questions.add(result!);
        else
          _questions[index] = result!;
      });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une question.')),
      );
      return;
    }
    setState(() => _busy = true);
    final ok = await boRun(context, () async {
      await widget.api.request(
        '/api/quizzes${widget.quiz == null ? '' : '/${widget.quiz!['id']}'}',
        method: widget.quiz == null ? 'POST' : 'PUT',
        data: {
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'passingScore': int.parse(_passing.text),
          'published': _published,
          'questions': _questions,
        },
      );
    });
    if (!mounted) return;
    if (ok)
      Navigator.pop(context, true);
    else
      setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.quiz == null ? 'Créer un quiz' : 'Modifier le quiz'),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _title,
            enabled: !_busy,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Renseignez un titre.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            enabled: !_busy,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passing,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Seuil de réussite (%)',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return n == null || n < 1 || n > 100
                  ? 'Choisissez un entier de 1 à 100.'
                  : null;
            },
          ),
          SwitchListTile(
            title: const Text('Publié'),
            value: _published,
            onChanged: _busy ? null : (v) => setState(() => _published = v),
          ),
          for (int i = 0; i < _questions.length; i++)
            BoCard(
              title: '${i + 1}. ${label(_questions[i], 'text')}',
              subtitle: '${records(_questions[i]['choices']).length} réponses',
              children: [
                Wrap(
                  children: [
                    TextButton(
                      onPressed: _busy ? null : () => _editQuestion(i),
                      child: const Text('Modifier'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _questions.removeAt(i)),
                      child: const Text('Retirer'),
                    ),
                    if (i > 0)
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                final q = _questions.removeAt(i);
                                _questions.insert(i - 1, q);
                              }),
                        child: const Text('Monter'),
                      ),
                  ],
                ),
              ],
            ),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _editQuestion(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une question'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Enregistrement…' : 'Enregistrer le quiz'),
          ),
        ],
      ),
    ),
  );
}

class MemberQuizHistory extends StatelessWidget {
  const MemberQuizHistory({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Mes résultats aux quiz',
    load: (a) => a.list('/api/mobile/quizzes/history'),
    tile: (c, a, q, r) => BoCard(
      title: label(q, 'quizTitle'),
      subtitle:
          '${q['score']} % · ${q['passed'] == true ? 'Réussi' : 'À retravailler'}\n${label(q, 'submittedAt').replaceAll('T', ' ')}',
    ),
  );
}
