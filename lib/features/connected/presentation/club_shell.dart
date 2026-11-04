import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/auth_storage.dart';
import '../../context/cubit/context_cubit.dart';
import '../../context/cubit/context_state.dart';
import '../../context/data/models/mobile_context_model.dart';
import '../../context/data/models/association_role.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'admin_pages.dart';
import 'events_page.dart';
import 'library_pages.dart';
import 'marketplace_pages.dart';
import 'quiz_pages.dart';

class ClubShell extends StatelessWidget {
  final ClubApi Function(int)? apiFactory;
  const ClubShell({super.key, this.apiFactory});
  @override
  Widget build(BuildContext context) => BlocBuilder<ContextCubit, ContextState>(
    builder: (context, state) {
      if (state.status == ContextStatus.loaded &&
          state.context?.currentAssociation != null) {
        return _ClubWorkspace(
          key: ValueKey(state.context!.currentAssociation!.associationId),
          data: state.context!,
          api: apiFactory?.call(
            state.context!.currentAssociation!.associationId,
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Multi-Asso'),
          actions: [
            TextButton(
              onPressed: () async {
                await AuthStorage().clear();
                if (context.mounted) context.go('/login');
              },
              child: const Text('Se reconnecter'),
            ),
          ],
        ),
        body: Center(
          child:
              state.status == ContextStatus.loading ||
                  state.status == ContextStatus.initial
              ? const CircularProgressIndicator()
              : StatusPanel(
                  title: state.status == ContextStatus.error
                      ? 'Connexion interrompue'
                      : 'Bienvenue chez vous',
                  message:
                      state.errorMessage ??
                      'Aucune association n’est rattachée à votre compte pour le moment.',
                  retry: () => context.read<ContextCubit>().loadContext(),
                ),
        ),
      );
    },
  );
}

class _ClubWorkspace extends StatefulWidget {
  final MobileContextModel data;
  final ClubApi? api;
  const _ClubWorkspace({super.key, required this.data, this.api});
  @override
  State<_ClubWorkspace> createState() => _ClubWorkspaceState();
}

class _ClubWorkspaceState extends State<_ClubWorkspace> {
  int _index = 0;
  late final _api =
      widget.api ?? ClubApi(widget.data.currentAssociation!.associationId);
  bool has(String module) =>
      widget.data.currentAssociation!.modules.contains(module);
  Future<void> _switchAssociation() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Mes associations',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
            ),
            ...widget.data.associations.map(
              (a) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: mint,
                  child: Text(
                    a.associationName.isEmpty ? 'A' : a.associationName[0],
                    style: const TextStyle(color: teal),
                  ),
                ),
                title: Text(a.associationName),
                subtitle: Text(a.role.label),
                trailing: a.associationId == _api.associationId
                    ? const Icon(Icons.check_circle, color: teal)
                    : null,
                onTap: () => Navigator.pop(context, a.associationId),
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen == null || chosen == _api.associationId || !mounted) return;
    await AuthStorage().saveActiveAssociationId(chosen);
    if (mounted) await context.read<ContextCubit>().loadContext();
  }

  Widget _module(
    String name,
    String subtitle,
    IconData icon,
    Widget page,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: mint,
        child: Icon(icon, color: teal),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => openPage(context, page),
    ),
  );
  List<Widget> _modules() => [
    if (widget.data.currentAssociation!.role == AssociationRole.admin)
      _module(
        'Espace administrateur',
        'Membres, justificatifs et messages',
        Icons.admin_panel_settings_outlined,
        ConnectedAdmin(
          api: _api,
          modules: widget.data.currentAssociation!.modules,
        ),
      ),
    if (has('PHOTO_GALLERY'))
      _module(
        'Galerie photo',
        'Les albums photo du club',
        Icons.photo_library_outlined,
        ConnectedGallery(api: _api),
      ),
    if (has('DOCUMENT_LIBRARY'))
      _module(
        'Bibliothèque',
        'Documents et ressources utiles',
        Icons.folder_outlined,
        ConnectedDocuments(api: _api),
      ),
    if (has('MARKETPLACE'))
      _module(
        'Petites annonces',
        'Petites annonces et bonnes trouvailles',
        Icons.storefront_outlined,
        ConnectedMarketplace(api: _api),
      ),
    if (has('QUIZ'))
      _module(
        'Quiz',
        'Quiz et progression',
        Icons.school_outlined,
        ConnectedQuizzes(api: _api),
      ),
  ];
  void _openAgenda() => openPage(
    context,
    Scaffold(
      appBar: AppBar(title: const Text('Les sorties à venir')),
      body: ConnectedEvents(api: _api, carpooling: has('CARPOOLING')),
    ),
  );

  Widget _home() {
    final firstName = widget.data.user.firstName;
    return OceanBackground(
      child: PageBody(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName.isEmpty ? 'Bienvenue 🤿' : 'Bonjour $firstName 🤿',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Les infos du club, vos prochaines sorties et les moments à partager.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (has('EVENTS')) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Prochaines sorties',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openAgenda,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('L’agenda'),
                ),
              ],
            ),
            ConnectedEvents(
              api: _api,
              carpooling: has('CARPOOLING'),
              compact: true,
            ),
            if (has('CARPOOLING'))
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: FilledButton.tonalIcon(
                  onPressed: _openAgenda,
                  icon: const Icon(Icons.directions_car_outlined),
                  label: const Text('Covoiturage · choisir une sortie'),
                ),
              ),
          ],
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16),
            child: Text(
              'La vie du club',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ..._modules(),
        ],
      ),
    );
  }

  Widget _profile() => PageBody(
    children: [
      Heading('Mon espace', 'Vos informations et vos associations.'),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: mint,
                child: Text(
                  widget.data.user.firstName.isEmpty
                      ? 'M'
                      : widget.data.user.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    color: teal,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.data.user.firstName} ${widget.data.user.lastName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.data.user.email),
              const SizedBox(height: 12),
              Tag(widget.data.currentAssociation!.role.label),
            ],
          ),
        ),
      ),
      _module(
        'Mes associations',
        '${widget.data.associations.length} association(s)',
        Icons.groups_outlined,
        _AssociationList(data: widget.data),
      ),
      if (has('QUIZ'))
        _module(
          'Mes résultats',
          'Retrouver mes tentatives de quiz',
          Icons.insights_outlined,
          QuizHistory(api: _api),
        ),
      OutlinedButton.icon(
        onPressed: _switchAssociation,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Changer d’association'),
      ),
      const SizedBox(height: 14),
      TextButton.icon(
        onPressed: () async {
          await AuthStorage().clear();
          if (mounted) context.go('/login');
        },
        icon: const Icon(Icons.logout),
        label: const Text('Me déconnecter'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      PageBody(
        children: [
          Heading(
            'Votre club',
            widget.data.currentAssociation!.associationName,
          ),
          ..._modules(),
        ],
      ),
      if (has('PHOTO_GALLERY')) ConnectedGallery(api: _api, embedded: true),
      if (has('MARKETPLACE')) ConnectedMarketplace(api: _api, embedded: true),
    ];
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _switchAssociation,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.data.currentAssociation!.logoUrl?.isNotEmpty == true)
                Image.network(
                  _api.imageUrl(widget.data.currentAssociation!.logoUrl!),
                  width: 48,
                  height: 48,
                  errorBuilder: (_, error, stack) =>
                      const Icon(Icons.groups_outlined, color: teal),
                )
              else if (widget.data.currentAssociation!.associationName
                  .toUpperCase()
                  .contains('ASASPP'))
                Image.asset(
                  'assets/pngs/logo_asaspp.png',
                  width: 56,
                  height: 56,
                )
              else
                const Icon(Icons.groups_outlined, color: teal, size: 30),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.data.currentAssociation!.associationName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mon profil',
            onPressed: () => openPage(
              context,
              Scaffold(
                appBar: AppBar(title: const Text('Mon profil')),
                body: _profile(),
              ),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: mint,
        elevation: 0,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Image.asset(
              'assets/pngs/plongeur1.png',
              width: 32,
              height: 32,
            ),
            label: 'Accueil',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Mon club',
          ),
          if (has('PHOTO_GALLERY'))
            const NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Galerie',
            ),
          if (has('MARKETPLACE'))
            const NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Annonces',
            ),
        ],
      ),
    );
  }
}

class _AssociationList extends StatelessWidget {
  final MobileContextModel data;
  const _AssociationList({required this.data});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes associations')),
    body: PageBody(
      children: data.associations
          .map(
            (a) => Card(
              child: ListTile(
                title: Text(a.associationName),
                subtitle: Text(a.role.label),
                leading: const Icon(Icons.groups_outlined),
              ),
            ),
          )
          .toList(),
    ),
  );
}
