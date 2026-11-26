import 'package:flutter/material.dart';
import 'admin_event_form.dart';

class CreateEventForm extends StatelessWidget {
  const CreateEventForm({super.key});
  @override
  Widget build(BuildContext context) => const AdminEventForm(training: false);
}
