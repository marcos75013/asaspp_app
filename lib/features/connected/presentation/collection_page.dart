import 'package:flutter/material.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';

typedef ItemBuilder =
    Widget Function(BuildContext context, Json item, VoidCallback refresh);

class CollectionPage extends StatefulWidget {
  final ClubApi api;
  final String path, title, subtitle, emptyMessage;
  final ItemBuilder itemBuilder;
  final Widget? action;
  final bool embedded;
  final Map<String, dynamic>? query;
  const CollectionPage({
    super.key,
    required this.api,
    required this.path,
    required this.title,
    required this.subtitle,
    required this.itemBuilder,
    this.emptyMessage =
        'Les contenus publiés par votre association apparaîtront ici.',
    this.action,
    this.query,
    this.embedded = false,
  });
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late Future<List<Json>> _future = _fetch();
  String _search = '';
  Future<List<Json>> _fetch() =>
      widget.api.list(widget.path, query: widget.query);
  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _future = future);
    // FutureBuilder displays errors; refresh completion must not leak them.
    try {
      await future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.embedded ? null : AppBar(title: Text(widget.title)),
    floatingActionButton: widget.action,
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: PageBody(
        children: [
          Heading(widget.title, widget.subtitle),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                setState(() => _search = value.toLowerCase().trim()),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Json>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return StatusPanel(
                  title: 'Une pause imprévue',
                  message: readableError(snapshot.error!),
                  retry: _refresh,
                );
              }
              final items = (snapshot.data ?? [])
                  .where(
                    (item) =>
                        '${label(item, 'title')} ${label(item, 'description')} ${label(item, 'categoryName')} ${label(item, 'firstName')} ${label(item, 'lastName')} ${label(item, 'email')} ${label(item, 'memberName')} ${label(item, 'quizTitle')} ${label(item, 'type')}'
                            .toLowerCase()
                            .contains(_search),
                  )
                  .toList();
              if (items.isEmpty) {
                return StatusPanel(
                  title: _search.isEmpty
                      ? 'Rien pour le moment'
                      : 'Aucun résultat',
                  message: _search.isEmpty
                      ? widget.emptyMessage
                      : 'Essayez un autre mot-clé.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items
                    .map((item) => widget.itemBuilder(context, item, _refresh))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 72),
        ],
      ),
    ),
  );
}
