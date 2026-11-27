import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_appearance.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../data/payment_links.dart';

class PaymentListPage extends StatefulWidget {
  final PaymentLinksRepository? repository;
  const PaymentListPage({super.key, this.repository});
  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  late final PaymentLinksRepository repository =
      widget.repository ?? PaymentLinksApi(ApiClient(AuthStorage()));
  late Future<List<PaymentLink>> payments;
  final appearance = PulseAppearance();

  @override
  void dispose() {
    appearance.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    payments = repository.list();
    appearance.restore(() => mounted);
  }

  void reload() => setState(() => payments = repository.list());
  Future<void> openPayment(PaymentLink item) async {
    try {
      final uri = Uri.parse(item.url);
      if (!['https', 'http'].contains(uri.scheme.toLowerCase()) ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Lien invalide');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d’ouvrir ce lien de paiement.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appearance,
    builder: (context, mode, _) {
      final brightness = switch (mode) {
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
      };
      return Theme(data: PulseTheme.build(brightness), child: _buildPage(mode));
    },
  );

  Widget _buildPage(ThemeMode mode) => Scaffold(
    appBar: AppBar(
      title: const Text('Paiements'),
      centerTitle: true,
      actions: [
        PopupMenuButton<ThemeMode>(
          tooltip: 'Apparence',
          icon: const Icon(Icons.brightness_6_outlined),
          initialValue: mode,
          onSelected: (mode) => appearance.select(mode, () => mounted),
          itemBuilder: (_) => const [
            PopupMenuItem(value: ThemeMode.system, child: Text('Système')),
            PopupMenuItem(value: ThemeMode.light, child: Text('Clair')),
            PopupMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
          ],
        ),
      ],
    ),
    body: FutureBuilder<List<PaymentLink>>(
      future: payments,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger les paiements.'),
                TextButton(onPressed: reload, child: const Text('Réessayer')),
              ],
            ),
          );
        }
        final links = snapshot.data ?? [];
        if (links.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Aucun lien de paiement disponible.'),
                TextButton(onPressed: reload, child: const Text('Actualiser')),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            reload();
            await payments;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: PulseTheme.pagePadding,
            itemCount: links.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  links[index].title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => openPayment(links[index]),
              ),
            ),
          ),
        );
      },
    ),
  );
}
