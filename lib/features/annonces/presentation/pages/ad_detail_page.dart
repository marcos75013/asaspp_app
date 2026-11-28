import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../user/data/profile_updates.dart';
import '../../data/services/ads_repository.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_image.dart';
import '../widgets/ad_photo_carousel.dart';

class AdDetailPage extends StatefulWidget {
  final AdModel ad;

  final AdsRepository? repository;

  const AdDetailPage({super.key, required this.ad, this.repository});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  late final _repository =
      widget.repository ?? MobileAdsApiService(ApiClient(AuthStorage()));
  AdModel? _freshAd;
  bool _updatingStatus = false;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    profileUpdates.addListener(_reloadAd);
    _reloadAd();
  }

  Future<void> _reloadAd() async {
    if (_updatingStatus) return;
    final version = ++_requestVersion;
    try {
      final ad = await _repository.getAd(widget.ad.id);
      if (mounted && version == _requestVersion) {
        setState(() => _freshAd = ad);
      }
    } catch (_) {
      // Keep the listing data available when the detail request fails.
    }
  }

  Future<void> _setStatus(AdModel ad, AdStatus status) async {
    if (!ad.isOwner || !ad.isActive || _updatingStatus) return;
    _requestVersion++;
    setState(() => _updatingStatus = true);
    try {
      final updated = await _repository.setStatus(ad.id, status);
      if (!mounted) return;
      setState(() => _freshAd = updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de modifier le statut.')),
      );
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
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
      child: PopScope(
        canPop: !_updatingStatus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Annonce'),
            leading: IconButton(
              tooltip: 'Retour aux annonces',
              onPressed: _updatingStatus
                  ? null
                  : () => Navigator.of(context).pop(),
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
                  AdPhotoCarousel(
                    key: ValueKey(ad.images.join('\n')),
                    adId: ad.id,
                    images: ad.images,
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
                  if (ad.isOwner) ...[
                    const Text(
                      'Gérer mon annonce',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(ad.visibilityLabel),
                    if (ad.isActive)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          OutlinedButton(
                            onPressed: _updatingStatus
                                ? null
                                : () => _setStatus(
                                    ad,
                                    ad.status == AdStatus.active
                                        ? AdStatus.closed
                                        : AdStatus.active,
                                  ),
                            child: Text(
                              ad.status == AdStatus.active
                                  ? 'Mettre en pause'
                                  : 'Remettre en ligne',
                            ),
                          ),
                          if (ad.status != AdStatus.sold &&
                              ad.type == AdType.vente)
                            OutlinedButton(
                              onPressed: _updatingStatus
                                  ? null
                                  : () => _setStatus(ad, AdStatus.sold),
                              child: const Text('Marquer comme vendue'),
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
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
      ),
    );
  }
}
