import 'package:asaspp_app/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the selected image without cropping it', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AssociationNavigationIcon(
          imageUrl: '/navigation-images/example',
          fallback: Icons.home,
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(
      (image.image as NetworkImage).url,
      endsWith('/navigation-images/example'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('uses the tab icon when no image is selected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AssociationNavigationIcon(fallback: Icons.home)),
    );
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
