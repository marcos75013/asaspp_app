import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DocumentsLibraryCard extends StatelessWidget {
  const DocumentsLibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/documents'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.8),
              Colors.cyan.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.folder_open, color: Colors.white, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Bibliothèque Plongée\nDocuments & Liens utiles",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}