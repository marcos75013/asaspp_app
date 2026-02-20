import 'package:flutter_bloc/flutter_bloc.dart';
import '../../demain/user_model.dart';

class UserCubit extends Cubit<UserModel> {
  UserCubit()
      : super(
    UserModel(
      nom: "Martins",
      prenom: "Marcos",
      email: "marcos@email.com",
      telephone: "06 12 34 56 78",
      licence: "FFESSM-123456",
      club: "ASASPP Plongée",
      niveau: "Niveau 2",
      nombrePlongees: 124,
      role: UserRole.admin,
    ),
  );

  void updateUser(UserModel user) {
    emit(user);
  }

  bool get isAdmin => state.role == UserRole.admin;
  bool get isBureau => state.role == UserRole.bureau;
}
