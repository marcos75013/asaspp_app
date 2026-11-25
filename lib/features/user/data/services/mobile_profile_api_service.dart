import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/models/mobile_user_model.dart';

class PreparedAvatar {
  final Uint8List bytes;
  final String filename;
  const PreparedAvatar(this.bytes, this.filename);
}

class AvatarPreparationException implements Exception {
  final String message;
  const AvatarPreparationException(this.message);
  @override
  String toString() => message;
}

class MobileProfileApiService {
  final ApiClient client;
  MobileProfileApiService(this.client);

  Future<MobileUserModel> getProfile() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/api/mobile/profile',
    );
    return MobileUserModel.fromJson(response.data ?? {});
  }

  Future<MobileUserModel> updateProfile({
    required String email,
    required String phone,
    String? currentPassword,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '/api/mobile/profile',
      data: {
        'email': email.trim(),
        'phone': phone.trim(),
        'currentPassword': currentPassword,
      },
    );
    final data = response.data!;
    final token = data['token'] as String?;
    if (token != null) {
      final storage = AuthStorage();
      final session = await storage.getSession();
      await storage.saveSession(token, session.refreshToken);
    }
    return MobileUserModel.fromJson(
      Map<String, dynamic>.from(data['user'] as Map),
    );
  }

  Future<MobileUserModel> uploadAvatar(PreparedAvatar avatar) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        avatar.bytes,
        filename: avatar.filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final response = await client.dio.put<Map<String, dynamic>>(
      '/api/mobile/profile/avatar',
      data: form,
    );
    return MobileUserModel.fromJson(response.data ?? {});
  }

  Future<MobileUserModel> deleteAvatar() async {
    final response = await client.dio.delete<Map<String, dynamic>>(
      '/api/mobile/profile/avatar',
    );
    return MobileUserModel.fromJson(response.data ?? {});
  }
}

class AvatarPreparer {
  static const maxBytes = 5 * 1024 * 1024;

  Future<PreparedAvatar> prepare(XFile image) async {
    final source = await image.readAsBytes();
    if (source.isEmpty)
      throw const AvatarPreparationException('La photo sélectionnée est vide.');
    final converted = await FlutterImageCompress.compressWithList(
      source,
      minWidth: 1024,
      minHeight: 1024,
      quality: 85,
      autoCorrectionAngle: true,
      keepExif: false,
      format: CompressFormat.jpeg,
    );
    if (converted.isEmpty || converted.length > maxBytes) {
      throw const AvatarPreparationException(
        'Photo invalide ou supérieure à 5 Mio.',
      );
    }
    final decoded = img.decodeJpg(converted);
    if (decoded == null || decoded.width > 4096 || decoded.height > 4096) {
      throw const AvatarPreparationException('Photo invalide ou trop grande.');
    }
    return PreparedAvatar(converted, 'avatar.jpg');
  }
}
