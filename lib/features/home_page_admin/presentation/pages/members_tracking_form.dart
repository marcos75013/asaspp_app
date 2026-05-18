import 'package:flutter/material.dart';

class MembersTrackingForm extends StatelessWidget {
  const MembersTrackingForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi des membres"),
      ),
      body: const Center(
        child: Text("Liste et suivi des membres"),
      ),
    );
  }
}