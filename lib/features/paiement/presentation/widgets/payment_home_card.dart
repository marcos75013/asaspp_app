import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentHomeCard extends StatelessWidget {
  const PaymentHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/payments'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00B4D8),
              Color(0xFF0077B6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: Colors.white, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                "Je paye ma commande",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white)
          ],
        ),
      ),
    );
  }
}