import '../data/models/ad_model.dart';

class AdsState {
  final List<AdModel> ads;
  final AdType? selectedFilter;
  final String searchQuery;
  final bool isLoading;

  AdsState({
    required this.ads,
    required this.selectedFilter,
    required this.searchQuery,
    required this.isLoading,
  });

  factory AdsState.initial() => AdsState(
    ads: [],
    selectedFilter: null,
    searchQuery: "",
    isLoading: false,
  );

  AdsState copyWith({
    List<AdModel>? ads,
    AdType? selectedFilter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}