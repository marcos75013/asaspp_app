import 'package:flutter/material.dart';

class CreateEventForm extends StatelessWidget {
  const CreateEventForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un événement"),
      ),
      body: const _CreateEventFormBody(),
    );
  }
}

class _CreateEventFormBody extends StatefulWidget {
  const _CreateEventFormBody();

  @override
  State<_CreateEventFormBody> createState() => _CreateEventFormBodyState();
}

class _CreateEventFormBodyState extends State<_CreateEventFormBody> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Form(
        key: _formKey,

        child: SingleChildScrollView(
          child: Column(
            children: [

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'événement",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Lieu",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print("Event créé");
                  }
                },
                child: const Text("Créer l'événement"),
              )
            ],
          ),
        ),
      ),
    );
  }
}