import 'package:flutter/material.dart';

class PaymentLinkForm extends StatelessWidget {
  const PaymentLinkForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter lien de paiement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                labelText: "Nom du paiement",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(
                labelText: "Lien de paiement",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Ajouter le lien"),
            )

          ],
        ),
      ),
    );
  }
}