import 'package:flutter/material.dart';

class DocumentForm extends StatelessWidget {
  const DocumentForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un document"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                labelText: "Nom du document",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Uploader document"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Enregistrer"),
            )

          ],
        ),
      ),
    );
  }
}