import 'package:flutter/material.dart';

import '../theme/pulse_theme.dart';

class PulseGradientHeading extends StatelessWidget {
  const PulseGradientHeading({
    super.key,
    required this.prefix,
    required this.accent,
  });

  final String prefix;
  final String accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w800,
    );
    final gradient = PulseTheme.headingGradient(theme.brightness);
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          text: '$prefix ',
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: gradient.createShader,
                child: Text(
                  accent,
                  style: style?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        style: style,
        semanticsLabel: '$prefix $accent',
      ),
    );
  }
}
