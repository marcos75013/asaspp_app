import 'package:asaspp_app/features/home/presentation/pages/club_message_card.dart';
import 'package:asaspp_app/features/messages/data/models/mobile_message_model.dart';
import 'package:asaspp_app/features/messages/data/services/mobile_message_repository.dart';
import 'package:asaspp_app/features/messages/presentation/cubit/message_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Messages implements MobileMessageRepository {
  @override
  Future<List<MobileMessageModel>> getPublishedMessages() async => [
    MobileMessageModel(
      id: 1,
      title: 'Premier message',
      content: 'Premier contenu complet',
      signature: 'Le bureau',
      createdAt: DateTime(2026, 11, 24),
    ),
    MobileMessageModel(
      id: 2,
      title: 'Deuxième message',
      content: 'Deuxième contenu complet',
      createdAt: DateTime(2026, 11, 23),
    ),
  ];
}

void main() {
  testWidgets('shows every published message and opens its full text', (
    tester,
  ) async {
    final cubit = MessageCubit(messageRepository: _Messages());
    await cubit.loadMessages();
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: ClubMessageCard())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Premier message'), findsOneWidget);
    expect(find.text('Deuxième message'), findsOneWidget);
    await tester.tap(find.text('Premier message'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Premier contenu complet'),
      ),
      findsOneWidget,
    );
    await cubit.close();
  });
}
