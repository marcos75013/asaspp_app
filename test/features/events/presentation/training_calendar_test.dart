import 'dart:convert';
import 'dart:typed_data';
import 'package:asaspp_app/core/config/api_config.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/events/presentation/pages/training_calendar_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adapter implements HttpClientAdapter {
  final bool fail;
  Adapter({this.fail = false});
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async {
    final items = [
      {
        'id': 1,
        'title': 'Séance future',
        'startDate': DateTime.now()
            .add(const Duration(days: 5))
            .toIso8601String(),
      },
      {
        'id': 2,
        'title': 'Séance passée',
        'startDate': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
    ];
    return ResponseBody.fromString(
      jsonEncode({'content': items, 'last': true}),
      fail ? 500 : 200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  testWidgets('shows upcoming and past trainings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final client = ApiClient(
      AuthStorage(),
      apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
    );
    client.dio.httpClientAdapter = Adapter();
    await tester.pumpWidget(
      MaterialApp(home: TrainingCalendarPage(apiClient: client)),
    );
    await tester.pumpAndSettle();
    expect(find.text('À venir'), findsOneWidget);
    expect(find.text('Terminés'), findsOneWidget);
    expect(find.text('Séance future'), findsOneWidget);
    expect(find.text('Séance passée'), findsOneWidget);
    expect(find.text('Présent'), findsOneWidget);
  });
  testWidgets('shows a retry when loading fails', (tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final client = ApiClient(
      AuthStorage(),
      apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
    );
    client.dio.httpClientAdapter = Adapter(fail: true);
    await tester.pumpWidget(
      MaterialApp(home: TrainingCalendarPage(apiClient: client)),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Impossible de charger les entraînements.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
