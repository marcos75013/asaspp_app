import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/gallery_mock_data.dart';
import '../../data/models/gallery_model.dart';
import 'gallery_detail_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String searchQuery = '';
  DateTimeRange? selectedRange;
  String selectedType = 'Tous';
  bool isLoading = true;

  final List<String> types = [
    'Tous',
    'Mer',
    'Fosse',
    'Carrière',
    'Nuit',
    'Apéro'
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => isLoading = false);
    });
  }

  List<GalleryModel> get filteredGalleries {
    return mockGalleries.where((gallery) {
      final matchesName =
      gallery.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesType =
          selectedType == 'Tous' || gallery.type == selectedType;

      final matchesDate = selectedRange == null ||
          (gallery.date.isAfter(
              selectedRange!.start.subtract(const Duration(days: 1))) &&
              gallery.date.isBefore(
                  selectedRange!.end.add(const Duration(days: 1))));

      return matchesName && matchesDate && matchesType;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool isNew(GalleryModel gallery) {
    return DateTime.now().difference(gallery.date).inDays <= 30;
  }

  Future<void> pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF005C97), // bleu sélection
              onPrimary: Colors.white,
              surface: Color(0xFF002B4F), // fond calendrier
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF001F3F),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() => selectedRange = range);
    }
  }


  void resetFilters() {
    setState(() {
      searchQuery = '';
      selectedRange = null;
      selectedType = 'Tous';
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleries = filteredGalleries;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/pngs/logo_asaspp.png',
              height: 40,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "On s'éclate à l'Asaspp",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F3F),
              Color(0xFF003B6F),
              Color(0xFF005C97),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [

              /// FILTER BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      buildSearchField(),
                      const SizedBox(height: 12),
                      buildFiltersRow(),
                    ],
                  ),
                ),
              ),

              /// RESULT COUNT
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 300),
                    child: Text(
                      "${galleries.length} sortie(s)",
                      key: ValueKey(galleries.length),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),

              /// GRID
              isLoading
                  ? SliverFillRemaining(child: buildShimmer())
                  : SliverPadding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: galleries.length,
                  itemBuilder: (context, index) {
                    final gallery = galleries[index];

                    return TweenAnimationBuilder(
                      duration: Duration(
                          milliseconds:
                          350 + index * 80),
                      tween: Tween(
                          begin: 0.8, end: 1.0),
                      builder:
                          (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child:
                      buildGalleryCard(gallery),
                    );
                  },
                ),
              ),
            ],
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: searchQuery.isNotEmpty
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search,
              color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(
                  color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Rechercher une sortie',
                hintStyle: TextStyle(
                    color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
              ),
              onChanged: (value) =>
                  setState(() => searchQuery = value),
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
        GestureDetector(
          onTap: resetFilters,
          child: const Icon(Icons.refresh,
              color: Colors.white70, size: 18),
        ),
      ],
    );
  }

  Widget buildTypeDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          dropdownColor: const Color(0xFF003B6F),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white70, size: 18),
          isExpanded: true,
          style:
          const TextStyle(color: Colors.white, fontSize: 13),
          items: types
              .map((type) => DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          ))
              .toList(),
          onChanged: (value) =>
              setState(() => selectedType = value!),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 15, color: Colors.white70),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                selectedRange == null
                    ? 'Période'
                    : "${DateFormat('dd/MM').format(selectedRange!.start)} - "
                    "${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}",
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGalleryCard(GalleryModel gallery) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GalleryDetailPage(gallery: gallery),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.asset(
              gallery.coverImage,
              fit: BoxFit.cover,
              height: 220,
              width: double.infinity,
            ),
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy')
                      .format(gallery.date),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11),
                ),
              ),
            ),

            if (isNew(gallery))
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Nouveau",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11),
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                gallery.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmer() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.white12,
        highlightColor: Colors.white24,
        child: Container(
          height: 200,
          width: 200,
          color: Colors.white,
        ),
      ),
    );
  }
}
