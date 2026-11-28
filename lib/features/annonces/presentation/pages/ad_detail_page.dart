import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../user/data/profile_updates.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_image.dart';

class AdDetailPage extends StatefulWidget {
  final AdModel ad;

  const AdDetailPage({super.key, required this.ad});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  AdModel? _freshAd;

  @override
  void initState() {
    super.initState();
    profileUpdates.addListener(_reloadAd);
    _reloadAd();
  }

  Future<void> _reloadAd() async {
    try {
      final ad = await MobileAdsApiService(
        ApiClient(AuthStorage()),
      ).getAd(widget.ad.id);
      if (mounted) setState(() => _freshAd = ad);
    } catch (_) {
      // Keep the current announcement visible if refreshing its author fails.
    }
  }

  Future<void> _contactSeller(AdModel ad) async {
    final phone = ad.contactPhone?.trim();
    final email = ad.sellerEmail?.trim();
    if ((phone == null || phone.isEmpty) && (email == null || email.isEmpty)) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (phone != null && phone.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(phone),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _openContact(Uri(scheme: 'tel', path: phone));
                },
              ),
            if (email != null && email.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(email),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _openContact(Uri(scheme: 'mailto', path: email));
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openContact(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le contact.')),
      );
    }
  }

  @override
  void dispose() {
    profileUpdates.removeListener(_reloadAd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _freshAd ?? widget.ad;

    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Annonce'),
          leading: IconButton(
            tooltip: 'Retour aux annonces',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Builder(
          builder: (context) {
            final accent = marketplaceAccent(context);
            final canContact =
                ad.contactPhone?.trim().isNotEmpty == true ||
                ad.sellerEmail?.trim().isNotEmpty == true;
            return ListView(
              padding: PulseTheme.pagePadding,
              children: [
                ClipRRect(
                  borderRadius: PulseTheme.cardRadius,
                  child: AspectRatio(
                    aspectRatio: 1.65,
                    child: Hero(
                      tag: ad.id,
                      child: AdImage(url: ad.image),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        ad.typeLabel,
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ad.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ad.priceLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ad.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ad.description,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Le vendeur',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: MemberAvatar(
                      radius: 20,
                      url: ad.sellerAvatar,
                      name: ad.sellerName,
                    ),
                    title: Text(
                      ad.sellerName.isEmpty ? 'Membre' : ad.sellerName,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: canContact ? () => _contactSeller(ad) : null,
                  child: const Text('Contacter le vendeur'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
