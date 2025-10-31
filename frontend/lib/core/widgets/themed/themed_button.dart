import 'package:flutter/material.dart';
import '../../theme/theme_tokens.dart';

class ThemedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool primary;

  const ThemedButton({super.key, required this.onPressed, required this.child, this.primary = true});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = primary
        ? ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: t.spaceLg, vertical: t.spaceSm),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusMd)),
          )
        : OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: t.spaceLg, vertical: t.spaceSm),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusMd)),
          );
    return primary
        ? ElevatedButton(onPressed: onPressed, style: style, child: child)
        : OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}

