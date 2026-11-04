import 'package:flutter_bloc/flutter_bloc.dart';
import '../../demain/user_model.dart';
import '../../../context/data/models/mobile_context_model.dart';

class UserCubit extends Cubit<UserModel> {
  UserCubit()
    : super(
        UserModel(
          nom: '',
          prenom: '',
          email: '',
          telephone: '',
          licence: '',
          club: '',
          niveau: '',
          nombrePlongees: null,
          role: UserRole.membre,
        ),
      );
  void setContext(MobileContextModel context) {
    final u = context.user;
    emit(
      UserModel(
        nom: u.lastName,
        prenom: u.firstName,
        email: u.email,
        telephone: u.phone ?? '',
        licence: 'Non renseignée',
        club: context.currentAssociation?.associationName ?? '',
        niveau: 'Non renseigné',
        nombrePlongees: null,
        role: context.currentAssociation?.role.name == 'admin'
            ? UserRole.admin
            : UserRole.membre,
      ),
    );
  }

  void updateUser(UserModel user) => emit(user);
  bool get isAdmin => state.role == UserRole.admin;
  bool get isBureau => state.role == UserRole.bureau;
}
