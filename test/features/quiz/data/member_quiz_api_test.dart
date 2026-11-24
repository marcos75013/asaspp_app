import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';

import 'package:asaspp_app/core/config/api_config.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/quiz/data/member_quiz_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QuizAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(
      requestStream == null
          ? ''
          : String.fromCharCodes(
              await requestStream.expand((chunk) => chunk).toList(),
            ),
    );
    final response = options.method == 'GET'
        ? '[{"id":5,"title":"Sécurité","description":"Test","passingScore":70,'
              '"questions":[{"index":1,"text":"Deuxième question","choices":['
              '{"index":2,"text":"B"},{"index":0,"text":"A"}]},'
              '{"index":0,"text":"Première question","choices":['
              '{"index":1,"text":"Oui"},{"index":0,"text":"Non"}]}]}]'
        : '{"score":100,"passed":true,"correctAnswers":2,"totalQuestions":2}';
    return ResponseBody.fromString(
      response,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'keeps shuffled question and choice indexes when submitting answers',
    () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final storage = AuthStorage();
      await storage.saveSession('token', null);
      await storage.saveActiveAssociationId(7);
      final adapter = _QuizAdapter();
      final client = ApiClient(
        storage,
        apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
      );
      client.dio.httpClientAdapter = adapter;
      final api = MemberQuizApiService(client);
      final quiz = (await api.list()).single;
      expect(quiz.questions.map((q) => q.index), [1, 0]);
      expect(quiz.questions.first.choices.map((c) => c.index), [2, 0]);
      final result = await api.submit(quiz, {1: 2, 0: 1});
      expect(result.score, 100);
      expect(adapter.requests[1].path, '/api/mobile/quizzes/5/attempts');
      expect(adapter.bodies[1], contains('"questionIndex":1,"choiceIndex":2'));
      expect(adapter.bodies[1], contains('"questionIndex":0,"choiceIndex":1'));
      expect(adapter.requests[1].headers['X-Association-Id'], '7');
    },
  );
}
