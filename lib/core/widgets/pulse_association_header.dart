import 'package:flutter/material.dart';

import '../config/api_config.dart';

class PulseAssociationHeader extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final String caption;
  final bool centered;
  final VoidCallback? onSwitch;

  const PulseAssociationHeader({
    super.key,
    required this.name,
    this.logoUrl,
    this.caption = 'ASSOCIATION ACTIVE',
    this.centered = false,
    this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const fallback = Icon(Icons.groups_outlined, size: 22);
    final logo = logoUrl?.trim();
    final content = Row(
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      children: [
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: logo == null || logo.isEmpty
                    ? fallback
                    : Image.network(
                        const ApiConfig().resolveUrl(logo),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => fallback,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          fit: centered ? FlexFit.loose : FlexFit.tight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: centered
                    ? theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 1,
                      )
                    : theme.textTheme.labelSmall,
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (onSwitch != null) const Icon(Icons.expand_more),
      ],
    );
    if (onSwitch == null) return content;
    return Tooltip(
      message: 'Changer d’association',
      child: InkWell(
        onTap: onSwitch,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: content,
        ),
      ),
    );
  }
}
