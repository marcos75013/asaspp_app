import 'package:asaspp_app/features/annonces/data/services/ads_repository.dart';
import 'package:asaspp_app/features/annonces/presentation/cubit/ad_cubit.dart';
import 'package:asaspp_app/features/annonces/presentation/data/models/ad_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdsRepository implements AdsRepository {
  final List<AdModel> ads;

  _FakeAdsRepository(this.ads);

  @override
  Future<List<AdModel>> getAds() async => [...ads];

  @override
  Future<AdModel> toggleFavorite(String id) async {
    final ad = ads.firstWhere((item) => item.id == id);
    return ad.copyWith(isFavorite: !ad.isFavorite);
  }
}

final _sale = AdModel(
  id: '1',
  title: 'Détendeur',
  description: 'Révisé',
  image: '',
  price: 100,
  sellerName: 'Jean',
  sellerAvatar: '',
  createdAt: DateTime(2026, 11, 12),
  type: AdType.vente,
);

void main() {
  test('loads listings and persists a favorite toggle', () async {
    final cubit = AdsCubit(_FakeAdsRepository([_sale]));

    await cubit.loadAds();
    expect(cubit.state.ads, hasLength(1));

    await cubit.toggleFavorite('1');
    expect(cubit.state.ads.single.isFavorite, isTrue);

    await cubit.close();
  });

  test('can clear a selected listing type', () async {
    final cubit = AdsCubit(_FakeAdsRepository([_sale]));
    await cubit.loadAds();

    cubit.filterByType(AdType.don);
    expect(cubit.getFilteredAds(), isEmpty);

    cubit.filterByType(null);
    expect(cubit.getFilteredAds(), hasLength(1));

    await cubit.close();
  });
}
