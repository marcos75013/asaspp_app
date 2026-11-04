import '../../connected/data/club_api.dart';
import '../../../core/data/association_repository.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

class DocumentsLibraryPage extends StatefulWidget {
  const DocumentsLibraryPage({super.key});

  @override
  State<DocumentsLibraryPage> createState() => _DocumentsLibraryPageState();
}

class _DocumentsLibraryPageState extends State<DocumentsLibraryPage> {
  String selectedCategory = "Tous";
  String search = "";

  List<Map<String, String>> documents = [];
  List<String> categories = ['Tous'];
  bool _loading = true;
  String? _error;
  final Set<String> _downloading = {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await repositoryOf(context).list('/api/documents');
      if (mounted)
        setState(() {
          documents = data
              .map(
                (d) => <String, String>{
                  'id': '${d['id']}',
                  'title': label(d, 'title'),
                  'subtitle': label(d, 'description'),
                  'type': label(d, 'contentType').contains('pdf')
                      ? 'PDF'
                      : 'Fichier',
                  'category': label(d, 'categoryName', 'Divers'),
                  'filename': label(d, 'originalFilename'),
                  'mime': label(d, 'contentType', 'application/octet-stream'),
                },
              )
              .toList();
          categories = {
            'Tous',
            ...documents.map((d) => d['category']!),
          }.toList();
          _error = null;
          _loading = false;
        });
    } catch (error) {
      if (mounted)
        setState(() {
          _error = readableError(error);
          _loading = false;
        });
    }
  }

  Future<void> _download(Map<String, String> doc) async {
    if (!_downloading.add(doc['id']!)) return;
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    try {
      final api = await repositoryOf(context).api();
      final bytes =
          await api.request(
                '/api/documents/${doc['id']}/download',
                responseType: ResponseType.bytes,
              )
              as List<int>;
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(Uint8List.fromList(bytes), mimeType: doc['mime']),
          ],
          fileNameOverrides: [doc['filename']!],
          sharePositionOrigin: origin,
        ),
      );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    } finally {
      _downloading.remove(doc['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = documents.where((doc) {
      final matchesCategory =
          selectedCategory == "Tous" || doc["category"] == selectedCategory;

      final matchesSearch = doc["title"]!.toLowerCase().contains(
        search.toLowerCase(),
      );

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
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: Column(
              children: [
                if (_loading || _error != null || documents.isEmpty)
                  DataStatus(
                    loading: _loading,
                    error: _error,
                    empty: 'Aucun document publié.',
                    reload: _load,
                  ),
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
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
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
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(color: Colors.white),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                    doc["type"] == "PDF" ? Icons.picture_as_pdf : Icons.link,
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
                    onPressed: () => _download(doc),
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
