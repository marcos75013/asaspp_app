import 'package:flutter/material.dart';

class CreateTrainingForm extends StatelessWidget {
  const CreateTrainingForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un entraînement"),
      ),
      body: const _CreateTrainingFormBody(),
    );
  }
}

class _CreateTrainingFormBody extends StatefulWidget {
  const _CreateTrainingFormBody();

  @override
  State<_CreateTrainingFormBody> createState() => _CreateTrainingFormBodyState();
}

class _CreateTrainingFormBodyState extends State<_CreateTrainingFormBody> {

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final placeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Form(
        key: _formKey,

        child: Column(
          children: [

            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Nom de l'entraînement",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: placeController,
              decoration: const InputDecoration(
                labelText: "Lieu",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Créer l'entraînement"),
            )

          ],
        ),
      ),
    );
  }
}