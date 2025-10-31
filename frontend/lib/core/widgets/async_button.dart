import 'package:flutter/material.dart';

class AsyncButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool outlined;

  const AsyncButton({super.key, required this.onPressed, required this.child, this.style, this.outlined = false});

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final btnChild = _loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary)),
          )
        : widget.child;

    final onPressed = widget.onPressed == null
        ? null
        : () async {
            if (_loading) return;
            setState(() => _loading = true);
            try {
              await widget.onPressed!.call();
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          };

    if (widget.outlined) {
      return OutlinedButton(onPressed: onPressed, style: widget.style, child: btnChild);
    }
    return FilledButton(onPressed: onPressed, style: widget.style, child: btnChild);
  }
}

