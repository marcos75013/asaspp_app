import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/events/presentation/pages/event_discussion_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'uses the occurrence id, pages backwards and removes only allowed messages',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final storage = AuthStorage();
      await storage.saveSession('token', null);
      await storage.saveActiveAssociationId(12);
      final client = ApiClient(storage);
      final calls = <RequestOptions>[];
      Map<String, dynamic> message(int id, bool canDelete) => {
        'id': id,
        'author': 'Camille',
        'body': 'Message $id',
        'own': false,
        'canDelete': canDelete,
        'createdAt': '2026-11-27T09:00:00Z',
      };
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            calls.add(request);
            final older = request.queryParameters['before'] != null;
            final data = switch (request.method) {
              'GET' => {
                'messages': [message(older ? 6 : 7, !older)],
                'nextBefore': older ? null : 7,
              },
              'POST' => message(8, true),
              _ => null,
            };
            handler.resolve(Response(requestOptions: request, data: data));
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: EventDiscussionPage(
            eventId: 42,
            title: 'Piscine',
            apiClient: client,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Message 7'), findsOneWidget);
      await tester.tap(find.text('Messages précédents'));
      await tester.pumpAndSettle();
      expect(find.text('Message 6'), findsOneWidget);
      expect(find.byTooltip('Retirer le message'), findsOneWidget);
      await tester.tap(find.byTooltip('Retirer le message'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer'));
      await tester.pumpAndSettle();
      expect(find.text('Message 7'), findsNothing);
      await tester.enterText(find.byType(TextField), ' Bonjour ');
      await tester.tap(find.byTooltip('Publier'));
      await tester.pumpAndSettle();
      expect(find.text('Message 8'), findsOneWidget);
      expect(calls.map((request) => request.method), [
        'GET',
        'GET',
        'DELETE',
        'POST',
      ]);
      expect(calls[1].queryParameters['before'], 7);
      expect(calls[2].path, '/api/events/42/discussion/7');
      expect(calls.last.path, '/api/events/42/discussion');
      expect(calls.last.data, {'body': 'Bonjour'});
      expect(
        calls.every(
          (request) =>
              request.headers['X-Association-Id'] == '12' &&
              request.headers['Authorization'] == 'Bearer token',
        ),
        isTrue,
      );
    },
  );
}
