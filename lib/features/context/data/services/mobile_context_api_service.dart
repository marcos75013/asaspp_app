import '../../../../core/network/api_client.dart';
import '../models/mobile_context_model.dart';

class MobileContextApiService {
  final ApiClient _apiClient;

  MobileContextApiService(this._apiClient);

  Future<MobileContextModel> getContext() async {
    final response = await _apiClient.dio.get('/api/mobile/context');

    return MobileContextModel.fromJson(response.data);
  }
}