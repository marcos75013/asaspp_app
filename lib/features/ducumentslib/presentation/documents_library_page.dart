import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsLibraryPage extends StatefulWidget {
  const DocumentsLibraryPage({super.key});

  @override
  State<DocumentsLibraryPage> createState() =>
      _DocumentsLibraryPageState();
}

class _DocumentsLibraryPageState extends State<DocumentsLibraryPage> {

  String selectedCategory = "Tous";
  String search = "";

  final List<Map<String, String>> documents = [
    {
      "title": "Règlement FFESSM 2024",
      "subtitle": "Fédération Française d'Études et de Sports Sous-Marins",
      "type": "PDF",
      "category": "Règlement",
      "url": "https://psp.ffessm.fr/les-reglements-officiels"
    },
    {
      "title": "Plongeur Merguez certifié ",
      "subtitle": "Modèle officiel à fournir annuellement",
      "type": "PDF",
      "category": "Médical",
      "url": "https://example.com/certificat.pdf"
    },
    {
      "title": "Tables MN90",
      "subtitle": "Tables officielles de décompression",
      "type": "PDF",
      "category": "Sécurité",
      "url": "https://ffessm-ctr-aura.fr/wp-content/uploads/2019/03/MN90.pdf"
    },
    {
      "title": "Certificat médical - CACI 2024/2025",
      "subtitle": "Lien vers le partenaire assurance",
      "type": "Lien",
      "category": "Divers",
      "url": "https://plongee.ffessm.fr/certificat-medical-caci"
    },
  ];

  List<String> categories = [
    "Tous",
    "Règlement",
    "Médical",
    "Sécurité",
    "Formation",
    "Divers"
  ];

  @override
  Widget build(BuildContext context) {

    final filteredDocs = documents.where((doc) {
      final matchesCategory =
          selectedCategory == "Tous" ||
              doc["category"] == selectedCategory;

      final matchesSearch =
      doc["title"]!.toLowerCase().contains(search.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Bibliothèque Plongée"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [

          /// 🌊 Background image
          Image.asset(
            "assets/pngs/mer.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          /// Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 16),

                /// 🔎 SEARCH BAR GLASS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        onChanged: (value) {
                          setState(() => search = value);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Rechercher un document...",
                          hintStyle:
                          const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🏷 CATEGORIES
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin:
                          const EdgeInsets.only(right: 10),
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.white.withOpacity(0.2),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// 📄 DOCUMENTS
                Expanded(
                  child: ListView.builder(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];

                      return _buildGlassCard(doc);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(Map<String, String> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [

                /// ICON
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc["type"] == "PDF"
                        ? Icons.picture_as_pdf
                        : Icons.link,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 14),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc["title"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc["subtitle"]!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// OPEN ICON
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(doc["url"]!);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}