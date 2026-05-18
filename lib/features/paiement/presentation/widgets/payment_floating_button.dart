import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentActionButton extends StatelessWidget {
  const PaymentActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: GestureDetector(
        onTap: () => context.push('/payments'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            /// 💳 Icône à gauche
            Icon(
              Icons.credit_card_rounded,
              color: Colors.black,
              size: 34,
            ),

            SizedBox(width: 12),

            /// 📝 Texte
            Text(
              "Payer ma commande",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}