import 'dart:io';
import 'dart:ui' as ui;

import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/cubit/context_state.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/services/mobile_context_api_service.dart';
import 'package:asaspp_app/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _DemoContext extends ContextCubit {
  _DemoContext()
    : super(
        contextApiService: MobileContextApiService(ApiClient(AuthStorage())),
        authStorage: AuthStorage(),
      ) {
    emit(
      ContextState(
        status: ContextStatus.loaded,
        context: MobileContextModel.fromJson({
          'user': {'id': 1, 'firstName': 'Camille'},
          'associations': [
            {
              'id': 1,
              'name': 'Club Pulse',
              'modules': ['QUIZ', 'DOCUMENT_LIBRARY'],
            },
          ],
        }),
      ),
    );
  }
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Accueil et Services à largeur mobile en $brightness', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.runAsync(_loadCaptureFonts);
      final cubit = _DemoContext();
      addTearDown(cubit.close);
      final capture = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            theme: PulseTheme.build(brightness),
            debugShowCheckedModeBanner: false,
            home: BlocProvider<ContextCubit>.value(
              value: cubit,
              child: const MainScaffold(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Salut, Camille !'), findsOneWidget);
      expect(find.text('Club Pulse'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, 'accueil-${brightness.name}');
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      expect(find.text('Apprendre et progresser'), findsOneWidget);
      expect(find.text('Vie pratique'), findsOneWidget);
      expect(find.text('Club Pulse'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, 'services-${brightness.name}');
    });
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  const output = String.fromEnvironment('PULSE_CAPTURE_DIR');
  if (output.isEmpty) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    try {
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await File('$output/$name.png').writeAsBytes(png.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _loadCaptureFonts() async {
  for (final (family, path) in [
    ('Roboto', const String.fromEnvironment('PULSE_TEXT_FONT')),
    ('MaterialIcons', const String.fromEnvironment('PULSE_ICON_FONT')),
  ]) {
    if (path.isEmpty) continue;
    final bytes = await File(path).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
