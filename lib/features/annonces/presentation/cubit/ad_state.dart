import '../data/models/ad_model.dart';

class AdsState {
  final List<AdModel> ads;
  final AdType? selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final bool favoritesOnly;
  final bool mineOnly;
  final String? errorMessage;

  AdsState({
    required this.ads,
    required this.selectedFilter,
    required this.searchQuery,
    required this.isLoading,
    this.favoritesOnly = false,
    this.mineOnly = false,
    required this.errorMessage,
  });

  factory AdsState.initial() => AdsState(
    ads: [],
    selectedFilter: null,
    searchQuery: "",
    isLoading: false,
    errorMessage: null,
  );

  AdsState copyWith({
    List<AdModel>? ads,
    AdType? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    bool? favoritesOnly,
    bool? mineOnly,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedFilter = false,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      selectedFilter: clearSelectedFilter
          ? null
          : selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      mineOnly: mineOnly ?? this.mineOnly,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
