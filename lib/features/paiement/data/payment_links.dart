import '../../../core/network/api_client.dart';

class PaymentLink {
  final int id;
  final String title;
  final String url;
  const PaymentLink({required this.id, required this.title, required this.url});
  factory PaymentLink.fromJson(Map<String, dynamic> json) => PaymentLink(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    url: json['url'] as String,
  );
}

abstract class PaymentLinksRepository {
  Future<List<PaymentLink>> list();
}

class PaymentLinksApi implements PaymentLinksRepository {
  final ApiClient client;
  PaymentLinksApi(this.client);
  @override
  Future<List<PaymentLink>> list() async {
    final response = await client.dio.get<List<dynamic>>('/api/payment-links');
    return (response.data ?? [])
        .map(
          (item) =>
              PaymentLink.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
