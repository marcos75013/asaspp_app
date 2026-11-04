// Standalone design review. Never imported by lib/main.dart.
// Every API response is a local fixture; mutations are deliberately rejected.
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/connected/data/club_api.dart';
import 'package:asaspp_app/app/router/app_router.dart';
import 'package:asaspp_app/core/data/association_repository.dart';
import 'package:asaspp_app/core/theme/app_theme.dart';
import 'package:asaspp_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asaspp_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/cubit/context_state.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/services/mobile_context_api_service.dart';

final previewContext = MobileContextModel.fromJson({
  'user': {
    'id': 1,
    'firstName': 'Camille',
    'lastName': 'Martin',
    'email': 'camille@example.org',
  },
  'associations': [
    {
      'associationId': 1,
      'associationName': 'ASASPP · Démonstration',
      'role': 'ADMIN',
      'modules': [
        'EVENTS',
        'CARPOOLING',
        'PHOTO_GALLERY',
        'DOCUMENT_LIBRARY',
        'MARKETPLACE',
        'QUIZ',
        'CLUB_COMMUNICATION',
      ],
    },
  ],
});

class PreviewContextCubit extends ContextCubit {
  PreviewContextCubit()
    : super(
        contextApiService: MobileContextApiService(ApiClient(AuthStorage())),
        authStorage: AuthStorage(),
      );
  @override
  Future<void> loadContext() async =>
      emit(ContextState(status: ContextStatus.loaded, context: previewContext));
}

class PreviewAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    dynamic data = [];
    var status = 200;
    if (options.method != 'GET') {
      status = 403;
    } else if (options.path == '/api/events') {
      data = {
        'last': true,
        'content': [
          {
            'id': 1,
            'title': 'Une échappée en mer',
            'category': 'Sortie plongée',
            'published': true,
            'description':
                'Une journée pour explorer les fonds marins et partager un moment au grand air.',
            'location': 'Marseille · Vieux-Port',
            'startDate': '2026-11-14T08:30:00',
            'endDate': '2026-11-14T17:00:00',
            'goingCount': 12,
            'capacity': 16,
            'waitlistedCount': 0,
            'currentUserStatus': 'GOING',
          },
          {
            'id': 2,
            'title': 'On se retrouve au bassin',
            'category': 'Entraînement',
            'published': true,
            'description': 'Un entraînement pour progresser ensemble.',
            'location': 'Piscine du club',
            'startDate': '2026-11-18T19:00:00',
            'goingCount': 8,
            'capacity': 20,
            'waitlistedCount': 0,
          },
        ],
      };
    } else if (options.path == '/api/documents') {
      data = [
        {
          'id': 1,
          'title': 'Préparer sa première sortie',
          'description': 'Les essentiels pour partir sereinement.',
          'categoryName': 'Vie du club',
          'fileSize': 245760,
          'originalFilename': 'guide.pdf',
        },
      ];
    } else if (options.path == '/api/gallery') {
      data = [
        {
          'id': 1,
          'title': 'Nos dernières aventures',
          'description': 'Des souvenirs plein la tête.',
          'photos': [],
        },
      ];
    } else if (options.path == '/api/marketplace') {
      data = [
        {
          'id': 1,
          'title': 'Combinaison en très bon état',
          'description': 'Une combinaison prête pour de nouvelles aventures.',
          'price': 80,
          'type': 'SALE',
          'images': [],
          'authorFirstName': 'Alex',
          'authorLastName': 'Martin',
          'favorite': false,
          'owner': false,
        },
      ];
    } else if (options.path == '/api/mobile/quizzes') {
      data = [
        {
          'id': 1,
          'title': 'Les bons réflexes en plongée',
          'description': 'Révisez les essentiels avant votre prochaine sortie.',
          'passingScore': 80,
          'questions': [
            {
              'index': 0,
              'text': 'Que vérifier avant une sortie ?',
              'choices': [
                {'index': 0, 'text': 'Son équipement'},
                {'index': 1, 'text': 'Rien'},
              ],
            },
          ],
        },
      ];
    }
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  final repository = AssociationRepository(
    injectedApi: ClubApi(
      1,
      client: Dio()..httpClientAdapter = PreviewAdapter(),
    ),
  );
  runApp(
    RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeCubit(repository)..loadEvents()),
          BlocProvider(create: (_) => UserCubit()..setContext(previewContext)),
          BlocProvider<ContextCubit>(create: (_) => PreviewContextCubit()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: GoRouter(
            initialLocation: '/home',
            routes: applicationRoutes,
          ),
          builder: (context, child) => Column(
            children: [
              const Material(
                color: Color(0xFFFFE5B0),
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'APERÇU · DONNÉES FICTIVES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF152536),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: child!),
            ],
          ),
        ),
      ),
    ),
  );
}
