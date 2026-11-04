import '../data/models/ad_model.dart';

class AdsState {
  final List<AdModel> ads;
  final AdType? selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  AdsState({
    required this.ads,
    required this.selectedFilter,
    required this.searchQuery,
    required this.isLoading,
    this.error,
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
    String? error,
    bool clearFilter = false,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      selectedFilter: clearFilter
          ? null
          : selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
