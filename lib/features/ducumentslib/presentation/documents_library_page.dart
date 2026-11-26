import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../data/models/association_document_model.dart';
import '../data/services/documents_repository.dart';
import '../data/services/mobile_documents_api_service.dart';

class DocumentsLibraryPage extends StatefulWidget {
  final DocumentsRepository? repository;

  const DocumentsLibraryPage({super.key, this.repository});

  @override
  State<DocumentsLibraryPage> createState() => _DocumentsLibraryPageState();
}

class _DocumentsLibraryPageState extends State<DocumentsLibraryPage> {
  int? selectedCategoryId;
  String search = "";
  List<AssociationDocumentModel> documents = const [];
  List<DocumentCategoryModel> categories = const [];
  bool loading = true;
  String? errorMessage;

  late final DocumentsRepository _repository =
      widget.repository ?? MobileDocumentsApiService(ApiClient(AuthStorage()));

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final values = await Future.wait([
        _repository.getPublishedDocuments(),
        _repository.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        documents = values[0] as List<AssociationDocumentModel>;
        categories = values[1] as List<DocumentCategoryModel>;
      });
    } catch (_) {
      if (mounted) setState(() => errorMessage = 'Chargement impossible.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openDocument(AssociationDocumentModel document) async {
    try {
      if (document.isLink) {
        final uri = Uri.tryParse(document.externalUrl!.trim());
        if (uri == null ||
            !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
            uri.host.isEmpty ||
            uri.userInfo.isNotEmpty) {
          throw StateError('Lien invalide');
        }
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw StateError('Aucune application disponible');
        }
      } else {
        await _repository.openFile(document);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir ce document.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = documents.where((doc) {
      final matchesCategory =
          selectedCategoryId == null || doc.categoryId == selectedCategoryId;

      final query = search.toLowerCase();
      final matchesSearch =
          doc.title.toLowerCase().contains(query) ||
          doc.originalFilename.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Bibliothèque"),
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
          Container(color: Colors.black.withValues(alpha: 0.4)),

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
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
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
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      final category = index == 0
                          ? null
                          : categories[index - 1];
                      final isSelected = category?.id == selectedCategoryId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = category?.id;
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
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category?.name ?? 'Tous',
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
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: loadDocuments,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : filteredDocs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Aucune ressource disponible.',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: loadDocuments,
                                child: const Text('Actualiser'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadDocuments,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];

                              return _buildGlassCard(doc);
                            },
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

  Widget _buildGlassCard(AssociationDocumentModel doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                /// ICON
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc.isLink
                        ? Icons.link
                        : doc.isPdf
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file_outlined,
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
                        doc.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.description.isEmpty
                            ? (doc.isLink
                                  ? '${doc.categoryName} · Lien'
                                  : '${doc.categoryName} · ${doc.originalFilename}')
                            : doc.description,
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
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () => openDocument(doc),
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
