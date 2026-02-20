import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ad_cubit.dart';
import '../data/models/ad_model.dart';
import '../pages/ad_detail_page.dart';

class AdCard extends StatelessWidget {
  final AdModel ad;

  const AdCard({super.key, required this.ad});

  String getPriceLabel() {
    if (ad.type == AdType.don) return "Gratuit";
    if (ad.type == AdType.recherche) return "Recherche";
    return "${ad.price.toStringAsFixed(0)}€";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// ✅ Navigation locale (compatible MainScaffold)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdDetailPage(ad: ad),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [

            /// HERO IMAGE
            Hero(
              tag: ad.id,
              child: Image.asset(
                ad.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// FAVORITE BUTTON
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  context.read<AdsCubit>().toggleFavorite(ad.id);
                },
                child: AnimatedScale(
                  scale: ad.isFavorite ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    ad.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: ad.isFavorite
                        ? Colors.red
                        : Colors.white,
                  ),
                ),
              ),
            ),

            /// TITLE + SELLER
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage:
                        AssetImage(ad.sellerAvatar),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ad.sellerName,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// PRICE BADGE
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getPriceLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
