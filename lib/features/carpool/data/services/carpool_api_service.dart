import '../../../../core/network/api_client.dart';
import '../models/carpool_model.dart';
import '../models/carpool_passenger.dart';

class CarpoolApiService {
  final ApiClient _client;
  const CarpoolApiService(this._client);

  Future<List<CarpoolModel>> list(int eventId) async {
    final response = await _client.dio.get<List<dynamic>>(
      '/api/events/$eventId/carpools',
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map((item) => CarpoolModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CarpoolModel> create(
    int eventId, {
    required String departureLocation,
    required DateTime departureTime,
    required int seatCount,
    String? note,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/events/$eventId/carpools',
      data: {
        'type': 'OFFER',
        'departureLocation': departureLocation.trim(),
        'departureTime': departureTime.toIso8601String(),
        'seatCount': seatCount,
        'note': note?.trim(),
      },
    );
    return CarpoolModel.fromJson(response.data ?? const {});
  }

  Future<List<CarpoolPassenger>> passengers(int postId) async {
    final response = await _client.dio.get<List<dynamic>>(
      '/api/carpools/$postId/passengers',
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map(
          (item) => CarpoolPassenger.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<CarpoolModel> book(int postId) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/carpools/$postId/bookings',
    );
    return CarpoolModel.fromJson(response.data ?? const {});
  }

  Future<CarpoolModel> cancelBooking(int postId) async {
    final response = await _client.dio.delete<Map<String, dynamic>>(
      '/api/carpools/$postId/bookings/mine',
    );
    return CarpoolModel.fromJson(response.data ?? const {});
  }
}
