import 'package:flutter/material.dart';

class SwipeDismissible extends StatelessWidget {
  final Key keyValue;
  final Widget child;
  final DismissDirection direction;
  final void Function(DismissDirection)? onDismissed;
  final String? confirmMessage;

  const SwipeDismissible({super.key, required this.keyValue, required this.child, this.direction = DismissDirection.endToStart, this.onDismissed, this.confirmMessage});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: keyValue,
      direction: direction,
      background: _buildBg(context, alignStart: true),
      secondaryBackground: _buildBg(context, alignStart: false),
      confirmDismiss: confirmMessage == null
          ? null
          : (dir) async {
              return await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Confirm'),
                      content: Text(confirmMessage!),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('OK')),
                      ],
                    ),
                  ) ??
                  false;
            },
      onDismissed: onDismissed,
      child: child,
    );
  }

  Widget _buildBg(BuildContext context, {required bool alignStart}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: scheme.error.withOpacity(0.12),
      child: Icon(Icons.delete_outline, color: scheme.error),
    );
  }
}

