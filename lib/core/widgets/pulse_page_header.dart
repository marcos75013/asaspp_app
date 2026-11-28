import 'package:flutter/material.dart';

import 'pulse_association_header.dart';

class PulsePageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PulsePageHeader({
    super.key,
    required this.title,
    this.associationName,
    this.logoUrl,
    this.backLabel = 'Retour',
    this.backEnabled = true,
  });

  final String title;
  final String? associationName;
  final String? logoUrl;
  final String backLabel;
  final bool backEnabled;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = associationName?.trim() ?? '';
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 64,
      leading: Navigator.of(context).canPop()
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Center(
                child: IconButton.outlined(
                  tooltip: backLabel,
                  onPressed: backEnabled
                      ? () => Navigator.of(context).maybePop()
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size.square(44),
                  ),
                  icon: const BackButtonIcon(),
                ),
              ),
            )
          : null,
      title: name.isEmpty
          ? Text(title)
          : PulseAssociationHeader(
              name: name,
              logoUrl: logoUrl,
              caption: 'MULTIASSO',
              centered: true,
            ),
    );
  }
}
