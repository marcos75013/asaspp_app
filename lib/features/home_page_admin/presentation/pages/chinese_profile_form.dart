import 'package:flutter/material.dart';

class ChineseProfileForm extends StatelessWidget {
  const ChineseProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil chinois"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                labelText: "Si j'étais un animal...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(
                labelText: "Si j'étais une couleur...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(
                labelText: "Si j'étais un lieu...",
                border: OutlineInputBorder(),
              ),
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