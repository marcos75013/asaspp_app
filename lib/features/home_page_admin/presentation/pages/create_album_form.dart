import 'package:flutter/material.dart';

class CreateAlbumForm extends StatelessWidget {
  const CreateAlbumForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un album photo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                labelText: "Nom de l'album",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Ajouter des photos"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Créer l'album"),
            )

          ],
        ),
      ),
    );
  }
}