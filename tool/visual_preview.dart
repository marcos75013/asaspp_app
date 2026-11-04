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
import 'package:asaspp_app/features/connected/presentation/club_shell.dart';
import 'package:asaspp_app/features/connected/presentation/club_widgets.dart';
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
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, state) => BlocProvider<ContextCubit>(
          create: (_) => PreviewContextCubit()..loadContext(),
          child: ClubShell(
            apiFactory: (id) => ClubApi(
              id,
              client: Dio()..httpClientAdapter = PreviewAdapter(),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Revenir à la démonstration'),
            ),
          ),
        ),
      ),
    ],
  );
  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: connectedTheme(),
      routerConfig: router,
      builder: (context, child) => Column(
        children: [
          Material(
            color: const Color(0xFFFFE5B0),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'APERÇU VISUEL · DONNÉES FICTIVES',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
  );
}
