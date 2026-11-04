import 'package:flutter/material.dart';
import '../data/club_api.dart';

const ink = Color(0xFF102D49);
const teal = Color(0xFF083E6D);
const mint = Color(0xFFE6F2FC);
const paper = Color(0xFFF4F8FC);

ThemeData connectedTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: teal,
    surface: Colors.white,
    primary: teal,
    onSurface: ink,
  ),
  scaffoldBackgroundColor: paper,
  appBarTheme: const AppBarTheme(
    backgroundColor: paper,
    foregroundColor: ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFDDE8F2)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    contentPadding: const EdgeInsets.all(18),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);

String dateLabel(dynamic raw) {
  final date = DateTime.tryParse(raw?.toString() ?? '');
  if (date == null) return 'Date à préciser';
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year} · '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
    children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ],
  );
}

class Heading extends StatelessWidget {
  final String title, subtitle;
  const Heading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: ink,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF536B80), height: 1.5),
        ),
      ],
    ),
  );
}

class StatusPanel extends StatelessWidget {
  final String title, message;
  final IconData icon;
  final VoidCallback? retry;
  const StatusPanel({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.retry,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: mint,
          child: Icon(icon, color: teal, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (retry != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: OutlinedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ),
      ],
    ),
  );
}

class ClubImage extends StatelessWidget {
  final String? url;
  final double height;
  const ClubImage(this.url, {super.key, this.height = 180});
  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      height: height,
      color: mint,
      alignment: Alignment.center,
      child: const Icon(Icons.landscape_outlined, size: 44, color: teal),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: url == null || url!.isEmpty
          ? fallback()
          : Image.network(
              url!,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => fallback(),
            ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: mint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: teal,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Future<void> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(readableError(error))));
    }
  }
}

void openPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

/// The original underwater artwork remains the visual anchor of the app.
class OceanBackground extends StatelessWidget {
  final Widget child;
  const OceanBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x28083E6D), Color(0xA0083E6D)],
          ),
        ),
      ),
      child,
    ],
  );
}
