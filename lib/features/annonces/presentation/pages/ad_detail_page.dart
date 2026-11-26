import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../user/data/profile_updates.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../data/models/ad_model.dart';

class AdDetailPage extends StatefulWidget {
  final AdModel ad;

  const AdDetailPage({super.key, required this.ad});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  final ScrollController _scrollController = ScrollController();
  AdModel? _freshAd;
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    profileUpdates.addListener(_reloadAd);
    _reloadAd();

    /// ⚡ Optimisation : limiter les rebuilds inutiles
    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      if ((offset - scrollOffset).abs() > 5) {
        setState(() {
          scrollOffset = offset;
        });
      }
    });
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _freshAd ?? widget.ad;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1E2D),
      body: Stack(
        children: [
          /// 🔥 PARALLAX IMAGE (léger)
          Positioned(
            top: -scrollOffset * 0.3,
            left: 0,
            right: 0,
            child: Hero(
              tag: ad.id,
              child: ad.image.isEmpty
                  ? Container(
                      height: 450,
                      color: const Color(0xFF16384F),
                      child: const Icon(
                        Icons.sell_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                    )
                  : Image.network(
                      ad.image,
                      height: 450,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
            ),
          ),

          /// 🧊 CONTENT (sans blur runtime)
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 350),

                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),

                      /// 🎨 Effet glass optimisé
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.92),
                          Colors.white.withValues(alpha: 0.85),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 25,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ad.type == AdType.don
                                ? "Gratuit"
                                : ad.type == AdType.recherche
                                ? "Recherche"
                                : "${ad.price.toStringAsFixed(0)}€",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          ad.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            MemberAvatar(
                              radius: 22,
                              url: ad.sellerAvatar,
                              name: ad.sellerName,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              ad.sellerName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed:
                                (ad.contactPhone?.trim().isNotEmpty == true ||
                                    ad.sellerEmail?.trim().isNotEmpty == true)
                                ? () => _contactSeller(ad)
                                : null,
                            child: const Text(
                              "Contacter le vendeur",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: IconButton(
                  tooltip: 'Retour aux annonces',
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
