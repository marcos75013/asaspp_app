import 'package:asaspp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the member login from splash', (tester) async {
    await tester.pumpWidget(const AsasppApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

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
}
