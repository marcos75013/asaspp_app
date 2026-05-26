import 'package:dio/dio.dart';

import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    print('🔥 AuthRemoteDataSource.login appelé');
    print('📧 email: $email');

    final response = await _dio.post(
      '/auth/token',
      data: {'email': email, 'password': password},
    );

    print('✅ Réponse backend: ${response.data}');

    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
