import '../../../../core/theme/pulse_theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/models/gallery_model.dart';
import '../../data/services/gallery_repository.dart';
import '../../data/services/mobile_gallery_api_service.dart';
import '../widgets/album_cover.dart';
import 'gallery_detail_page.dart';

class GalleryPage extends StatefulWidget {
  final GalleryRepository? repository;

  const GalleryPage({super.key, this.repository});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _search = TextEditingController();
  String searchQuery = '';
  DateTimeRange? selectedRange;
  String selectedType = 'Tous';
  bool isLoading = true;
  String? errorMessage;
  List<GalleryModel> galleries = const [];

  List<String> get types => [
    'Tous',
    ...{for (final gallery in galleries) gallery.type}.toList()..sort(),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(loadGalleries());
  }

  Future<void> loadGalleries() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      galleries = const [];
    });

    try {
      final repository =
          widget.repository ??
          MobileGalleryApiService(ApiClient(AuthStorage()));
      final albums = await repository.getPublishedAlbums();
      if (!mounted) return;
      setState(() {
        galleries = albums;
        if (!types.contains(selectedType)) selectedType = 'Tous';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = 'Impossible de charger les albums.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<GalleryModel> get filteredGalleries {
    return galleries.where((gallery) {
      final matchesName = gallery.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesType =
          selectedType == 'Tous' || gallery.type == selectedType;

      final matchesDate =
          selectedRange == null ||
          (gallery.date.isAfter(
                selectedRange!.start.subtract(const Duration(days: 1)),
              ) &&
              gallery.date.isBefore(
                selectedRange!.end.add(const Duration(days: 1)),
              ));

      return matchesName && matchesDate && matchesType;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedRange,
      builder: (context, child) => Theme(data: _pulse, child: child!),
    );

    if (mounted && range != null) {
      setState(() => selectedRange = range);
    }
  }

  void resetFilters() {
    _search.clear();
    setState(() {
      searchQuery = '';
      selectedRange = null;
      selectedType = 'Tous';
    });
  }

  ThemeData get _pulse => PulseTheme.build(Theme.of(context).brightness);
  ColorScheme get _colors => _pulse.colorScheme;

  @override
  Widget build(BuildContext context) {
    final galleries = filteredGalleries;

    return Theme(
      data: _pulse,
      child: Scaffold(
        appBar: AppBar(title: const Text('Galerie')),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadGalleries,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: PulseTheme.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nos souvenirs',
                          style: _pulse.textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        buildSearchField(),
                        const SizedBox(height: 10),
                        buildFiltersRow(),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (errorMessage case final error?)
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: Text(error),
                      trailing: TextButton(
                        onPressed: loadGalleries,
                        child: const Text('Réessayer'),
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Les albums',
                              style: _pulse.textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${galleries.length} album${galleries.length == 1 ? '' : 's'}',
                            style: TextStyle(color: _colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (galleries.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PulseTheme.pagePadding,
                        child: Text(
                          this.galleries.isEmpty
                              ? 'Aucun album publié.'
                              : 'Aucun album ne correspond aux filtres.',
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      sliver: SliverToBoxAdapter(
                        child: buildGalleryCard(galleries.first, 2),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.35,
                            ),
                        itemCount: galleries.length - 1,
                        itemBuilder: (context, index) =>
                            buildGalleryCard(galleries[index + 1], 1.35),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: searchQuery.isNotEmpty
              ? _colors.primary
              : _colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: _colors.onSurfaceVariant, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _search,
              style: TextStyle(color: _colors.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher une sortie',
                hintStyle: TextStyle(
                  color: _colors.onSurfaceVariant,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFiltersRow() {
    return Row(
      children: [
        Expanded(flex: 2, child: buildTypeDropdown()),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: buildDateButton()),
        const SizedBox(width: 8),
        IconButton(
          onPressed: resetFilters,
          tooltip: 'Réinitialiser les filtres',
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget buildTypeDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          dropdownColor: _colors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: _colors.onSurfaceVariant,
            size: 18,
          ),
          isExpanded: true,
          style: _pulse.textTheme.labelLarge?.copyWith(
            color: _colors.onSurface,
            fontSize: 13,
          ),
          items: types
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => selectedType = value!),
        ),
      ),
    );
  }

  Widget buildDateButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: pickDateRange,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _colors.surface,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 15,
              color: _colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                selectedRange == null
                    ? 'Période'
                    : "${DateFormat('dd/MM').format(selectedRange!.start)} - "
                          "${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}",
                style: TextStyle(color: _colors.onSurface, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGalleryCard(GalleryModel gallery, double aspectRatio) =>
      AlbumCover(
        album: gallery,
        aspectRatio: aspectRatio,
        showPhotoCount: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GalleryDetailPage(gallery: gallery),
          ),
        ),
      );
}
