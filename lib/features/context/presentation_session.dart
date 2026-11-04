import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data/association_repository.dart';
import '../../main_scaffold.dart';
import '../home/presentation/cubit/home_cubit.dart';
import '../user/presentation/cubit/user_cubit.dart';
import 'cubit/context_cubit.dart';
import 'cubit/context_state.dart';

class AssociationSession extends StatefulWidget {
  const AssociationSession({super.key});
  @override
  State<AssociationSession> createState() => _AssociationSessionState();
}

class _AssociationSessionState extends State<AssociationSession> {
  @override
  void initState() {
    super.initState();
    context.read<ContextCubit>().loadContext();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ContextCubit, ContextState>(
        listener: (context, state) {
          if (state.status == ContextStatus.loaded && state.context != null) {
            context.read<UserCubit>().setContext(state.context!);
            context.read<HomeCubit>().loadEvents();
          }
        },
        builder: (context, state) {
          if (state.status == ContextStatus.loaded &&
              state.context?.currentAssociation != null) {
            return MainScaffold(
              key: ValueKey(state.context!.currentAssociation!.associationId),
            );
          }
          return Scaffold(
            body: Center(
              child: DataStatus(
                loading: state.status == ContextStatus.loading,
                error: state.errorMessage,
                empty: 'Aucune association associée à ce compte.',
                reload: () => context.read<ContextCubit>().loadContext(),
              ),
            ),
          );
        },
      );
}
