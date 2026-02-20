import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/models/ad_model.dart';

class AdDetailPage extends StatefulWidget {
  final AdModel ad;

  const AdDetailPage({
    super.key,
    required this.ad,
  });

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1E2D),
      body: Stack(
        children: [

          /// 🔥 PARALLAX IMAGE
          Positioned(
            top: -scrollOffset * 0.4,
            left: 0,
            right: 0,
            child: Hero(
              tag: ad.id,
              child: Image.asset(
                ad.image,
                height: 450,
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔙 BACK BUTTON (Navigator)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🧊 CONTENT
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 350),

                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20,
                      sigmaY: 20,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius:
                        const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            ad.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFF00B4D8),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              ad.type == AdType.don
                                  ? "Gratuit"
                                  : ad.type ==
                                  AdType.recherche
                                  ? "Recherche"
                                  : "${ad.price.toStringAsFixed(0)}€",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            ad.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                AssetImage(
                                    ad.sellerAvatar),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ad.sellerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                    0xFF00B4D8),
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 16,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      20),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Contacter le vendeur",
                                style: TextStyle(
                                    fontSize: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
