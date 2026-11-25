import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/data/models/mobile_user_model.dart';
import 'package:asaspp_app/features/context/data/services/mobile_context_api_service.dart';
import 'package:asaspp_app/features/user/data/services/mobile_profile_api_service.dart';
import 'package:asaspp_app/features/user/presentation/pages/user_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const user = MobileUserModel(
  id: 1,
  email: 'alice@example.com',
  firstName: 'Alice',
  lastName: 'Martin',
  phone: '0600000000',
);

class FakeProfile extends MobileProfileApiService {
  FakeProfile() : super(ApiClient(AuthStorage()));
  @override
  Future<MobileUserModel> getProfile() async => user;
}

void main() {
  testWidgets('profile shows photo controls and edits only email and phone', (
    tester,
  ) async {
    final client = ApiClient(AuthStorage());
    final cubit = ContextCubit(
      contextApiService: MobileContextApiService(client),
      authStorage: AuthStorage(),
    );
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          home: Scaffold(
            body: UserProfileSheet(user: user, profileService: FakeProfile()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choisir une photo'), findsOneWidget);
    expect(find.text('Modules disponibles'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Modifier mon profil'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Modifier mon profil'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Téléphone'), findsWidgets);
    await tester.enterText(
      find.byType(TextFormField).first,
      'nouveau@example.com',
    );
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe actuel'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    await cubit.close();
  });
}
