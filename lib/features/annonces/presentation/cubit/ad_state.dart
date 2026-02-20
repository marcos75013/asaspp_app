import '../data/models/ad_model.dart';

class AdsState {
  final List<AdModel> ads;
  final AdType? selectedFilter;
  final bool isLoading;

  AdsState({
    required this.ads,
    required this.selectedFilter,
    required this.isLoading,
  });

  factory AdsState.initial() => AdsState(
    ads: [],
    selectedFilter: null,
    isLoading: false,
  );

  AdsState copyWith({
    List<AdModel>? ads,
    AdType? selectedFilter,
    bool? isLoading,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
