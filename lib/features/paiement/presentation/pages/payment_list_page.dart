import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentItem {
  final String title;
  final String url;

  PaymentItem({required this.title, required this.url});
}

class PaymentListPage extends StatelessWidget {
  const PaymentListPage({super.key});

  static final List<PaymentItem> payments = [
    PaymentItem(
      title: "Adhésion annuelle 2025/2026",
      url: "https://www.helloasso.com/exemple-adhesion",
    ),
    PaymentItem(
      title: "Stage Niolon Juin 2026",
      url: "https://www.helloasso.com/exemple-sortie",
    ),
    PaymentItem(
      title: "Cagnote Voyage Mexique 2027",
      url: "https://www.helloasso.com/exemple-sortie",
    ),
    PaymentItem(
      title: "Passage de Niveau 1",
      url: "https://www.stripe.com/exemple",
    ),
    PaymentItem(
      title: "Passage de Niveau 2",
      url: "https://www.stripe.com/exemple",
    ),
    PaymentItem(
      title: "Passage de Niveau 3",
      url: "https://www.stripe.com/exemple",
    ),
  ];

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Impossible d'ouvrir $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Paiements"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// 🔵 LOGO ASASPP
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                "assets/pngs/logo_asaspp.png",
                height: 120,
              ),
            ),
          ),

          /// 🔵 LISTE DES PAIEMENTS
          ...payments.map((item) {
            return GestureDetector(
              onTap: () => _openUrl(item.url),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: Color(0xFF0077B6)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 18)
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}