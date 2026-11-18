import '../../../core/network/api_client.dart';
import 'member_quiz.dart';

class MemberQuizApiService {
  final ApiClient _client;
  const MemberQuizApiService(this._client);

  Future<List<MemberQuiz>> list() async {
    final response = await _client.dio.get<List<dynamic>>(
      '/api/mobile/quizzes',
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map((item) => MemberQuiz.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MemberQuizResult> submit(
    MemberQuiz quiz,
    Map<int, int> answers,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/mobile/quizzes/${quiz.id}/attempts',
      data: {
        'answers': [
          for (final question in quiz.questions)
            {
              'questionIndex': question.index,
              'choiceIndex': answers[question.index],
            },
        ],
      },
    );
    return MemberQuizResult.fromJson(response.data ?? const {});
  }
}
