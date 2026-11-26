import 'package:asaspp_app/features/paiement/data/payment_links.dart';
import 'package:asaspp_app/features/paiement/presentation/pages/payment_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePayments implements PaymentLinksRepository {
  final List<PaymentLink> links;
  final bool fail;
  FakePayments(this.links, {this.fail = false});
  @override
  Future<List<PaymentLink>> list() async {
    if (fail) throw Exception('network');
    return links;
  }
}

void main() {
  testWidgets('affiche les liens transmis par le backend', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentListPage(
          repository: FakePayments([
            const PaymentLink(
              id: 1,
              title: 'Cotisation',
              url: 'https://example.com',
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cotisation'), findsOneWidget);
    expect(find.text('Adhésion annuelle 2025/2026'), findsNothing);
  });
  testWidgets('présente un état vide et une erreur avec relance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PaymentListPage(repository: FakePayments([]))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aucun lien de paiement disponible.'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentListPage(
          key: const ValueKey('error'),
          repository: FakePayments([], fail: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger les paiements.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
