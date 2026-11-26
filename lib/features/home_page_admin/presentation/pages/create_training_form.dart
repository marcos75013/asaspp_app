import 'package:flutter/material.dart';
import 'admin_event_form.dart';

class CreateTrainingForm extends StatelessWidget {
  const CreateTrainingForm({super.key});
  @override
  Widget build(BuildContext context) => const AdminEventForm(training: true);
}
