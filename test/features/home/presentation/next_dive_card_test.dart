import 'package:asaspp_app/features/home/data/models/next_event_model.dart';
import 'package:asaspp_app/features/home/presentation/pages/next_dive_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the event title, location and readable date', (
    tester,
  ) async {
    final event = NextEventModel(
      id: 7,
      title: 'NIOLON 2027',
      site: 'Niolon UCPA',
      startDate: DateTime(2027, 2, 12, 15, 11),
      diveType: DiveType.stage,
      message: 'Stage N2 et N3',
      category: 'Stage',
      goingCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 390,
              height: 230,
              child: NextDiveCard(event: event),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NIOLON 2027'), findsOneWidget);
    expect(find.text('STAGE'), findsOneWidget);
    expect(find.text('2 participant(s)'), findsOneWidget);
    expect(find.text('Niolon UCPA'), findsOneWidget);
    final dateText = tester.widget<Text>(find.text(event.date));
    expect(dateText.style?.color, const Color(0xFF34445A));
    expect(tester.takeException(), isNull);
  });
}
