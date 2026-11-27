import 'package:asaspp_app/app/router/app_router.dart';
import 'package:asaspp_app/core/network/auth_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asaspp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    sessionExpired.value = false;
    appRouter.go('/splash');
  });
  tearDown(() => sessionExpired.value = false);

  testWidgets('opens the member login from splash', (tester) async {
    await tester.pumpWidget(const AsasppApp());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/pngs/logo_multiasso.png',
      ),
      findsOneWidget,
    );
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
  testWidgets('a closed session redirects protected navigation to login', (
    tester,
  ) async {
    await tester.pumpWidget(const AsasppApp());
    await tester.pumpAndSettle();
    sessionExpired.value = true;
    appRouter.go('/admin-home');
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
    expect(appRouter.routeInformationProvider.value.uri.path, '/login');
  });
}
