import '../../../../../core/network/api_client.dart';
import '../models/mobile_login_request.dart';
import '../models/mobile_login_response.dart';

class MobileAuthApiService {
  final ApiClient _apiClient;

  MobileAuthApiService(this._apiClient);

  Future<MobileLoginResponse> login(MobileLoginRequest request) async {
    final response = await _apiClient.dio.post(
      '/api/mobile/auth/token',
      data: request.toJson(),
    );

    return MobileLoginResponse.fromJson(response.data);
  }
}