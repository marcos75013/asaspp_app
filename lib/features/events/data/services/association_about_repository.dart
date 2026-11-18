import '../../../../core/network/api_client.dart';
import '../models/association_about.dart';

abstract interface class AssociationAboutRepository {
  Future<AssociationAbout> load();
}

class AssociationAboutApiService implements AssociationAboutRepository {
  final ApiClient client;
  AssociationAboutApiService(this.client);

  @override
  Future<AssociationAbout> load() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/api/mobile/association/about',
    );
    return AssociationAbout.fromJson(response.data ?? {});
  }
}
