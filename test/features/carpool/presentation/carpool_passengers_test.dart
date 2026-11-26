import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/carpool/data/models/carpool_model.dart';
import 'package:asaspp_app/features/carpool/data/models/carpool_passenger.dart';
import 'package:asaspp_app/features/carpool/data/services/carpool_api_service.dart';
import 'package:asaspp_app/features/carpool/presentation/pages/join_carpool_screen.dart';
import 'package:asaspp_app/features/home/data/models/next_event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCarpools extends CarpoolApiService {
  FakeCarpools(this.posts) : super(ApiClient(AuthStorage()));
  final List<CarpoolModel> posts;
  int books = 0;
  @override
  Future<List<CarpoolModel>> list(int eventId) async => posts;
  @override
  Future<List<CarpoolPassenger>> passengers(int postId) async => [
    const CarpoolPassenger(id: 1, name: 'Alice Martin'),
  ];
  @override
  Future<CarpoolModel> book(int postId) async {
    books++;
    return posts.first;
  }
}

CarpoolModel post(int id, String name, {bool own = false}) => CarpoolModel(
  id: id,
  eventId: 4,
  creatorName: name,
  departureLocation: 'Gare',
  departureTime: DateTime(2099),
  totalSeats: 3,
  remainingSeats: 2,
  bookedByCurrentUser: false,
  ownedByCurrentUser: own,
  active: true,
  type: 'OFFER',
);
final event = NextEventModel(
  id: 4,
  title: 'Sortie',
  site: 'Paris',
  startDate: DateTime(2099),
  diveType: DiveType.autre,
  message: '',
);
void main() {
  testWidgets('driver sees passengers and cannot reserve another carpool', (
    tester,
  ) async {
    final api = FakeCarpools([
      post(1, 'Mon covoiturage', own: true),
      post(2, 'Autre conducteur'),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: JoinCarpoolScreen(event: event, api: api),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('tu ne peux pas réserver'), findsOneWidget);
    final reserve = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Réserver'),
    );
    expect(reserve.onPressed, isNull);
    await tester.tap(find.text('Voir les passagers'));
    await tester.pumpAndSettle();
    expect(find.text('Alice Martin'), findsOneWidget);
    expect(api.books, 0);
  });
  testWidgets('a member who is not a driver can reserve', (tester) async {
    final api = FakeCarpools([post(2, 'Autre conducteur')]);
    await tester.pumpWidget(
      MaterialApp(
        home: JoinCarpoolScreen(event: event, api: api),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Réserver'),
          )
          .onPressed,
      isNotNull,
    );
    expect(find.text('Voir les passagers'), findsNothing);
  });
}
