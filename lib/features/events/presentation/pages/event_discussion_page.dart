import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/pulse_theme.dart';

class EventDiscussionPage extends StatefulWidget {
  final int eventId;
  final String title;
  final ApiClient apiClient;

  const EventDiscussionPage({
    super.key,
    required this.eventId,
    required this.title,
    required this.apiClient,
  });

  @override
  State<EventDiscussionPage> createState() => _EventDiscussionPageState();
}

class _EventDiscussionPageState extends State<EventDiscussionPage> {
  final _body = TextEditingController();
  final _messages = <Map<String, dynamic>>[];
  int? _nextBefore;
  bool _busy = false;
  bool _loaded = false;
  String? _error;
  String get _path => '/api/events/${widget.eventId}/discussion';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _fetch({int? before}) async {
    final result = await widget.apiClient.dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: {if (before != null) 'before': before},
    );
    final page = result.data!;
    final messages = (page['messages'] as List).cast<Map<String, dynamic>>();
    if (!mounted) return;
    setState(() {
      if (before == null) _messages.clear();
      final ids = _messages.map((message) => message['id']).toSet();
      _messages.addAll(messages.where((message) => ids.add(message['id'])));
      _nextBefore = (page['nextBefore'] as num?)?.toInt();
      _loaded = true;
    });
  }

  Future<void> _run(Future<void> Function() action, String error) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load({int? before}) => _run(
    () => _fetch(before: before),
    'Impossible de charger la discussion.',
  );

  Future<void> _send() async {
    final body = _body.text.trim();
    if (body.isEmpty || body.length > 2000) return;
    await _run(() async {
      final result = await widget.apiClient.dio.post<Map<String, dynamic>>(
        _path,
        data: {'body': body},
      );
      if (!mounted) return;
      setState(() {
        _body.clear();
        final message = result.data!;
        _messages.removeWhere((item) => item['id'] == message['id']);
        _messages.insert(0, message);
      });
    }, 'Impossible de publier le message.');
  }

  Future<void> _delete(Map<String, dynamic> message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ce message ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _run(() async {
      await widget.apiClient.dio.delete<void>('$_path/${message['id']}');
      if (mounted) setState(() => _messages.remove(message));
    }, 'Impossible de retirer le message.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discussion'),
          actions: [
            IconButton(
              tooltip: 'Actualiser',
              onPressed: _busy ? null : () => _load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_busy) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _load(),
                  child: ListView(
                    padding: PulseTheme.pagePadding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(widget.title, style: theme.textTheme.titleLarge),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _error!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      if (_loaded && _messages.isEmpty && !_busy)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Aucun message pour cette date.'),
                        ),
                      for (final message in _messages)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message['own'] == true
                                            ? 'Vous'
                                            : message['author'] as String,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                    if (message['canDelete'] == true)
                                      IconButton(
                                        tooltip: 'Retirer le message',
                                        onPressed: _busy
                                            ? null
                                            : () => _delete(message),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                  ],
                                ),
                                Text(message['body'] as String),
                                if (DateTime.tryParse(
                                      message['createdAt'] as String? ?? '',
                                    )
                                    case final date?)
                                  Text(
                                    MaterialLocalizations.of(
                                      context,
                                    ).formatShortDate(date.toLocal()),
                                    style: theme.textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (_nextBefore != null)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _load(before: _nextBefore),
                          child: const Text('Messages précédents'),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _body,
                        enabled: !_busy,
                        maxLength: 2000,
                        maxLines: 3,
                        minLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Votre message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Publier',
                      onPressed: _busy ? null : _send,
                      icon: const Icon(Icons.send_outlined),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
