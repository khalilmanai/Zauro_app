import 'package:flutter/material.dart';

typedef ErrorBuilder = Widget Function(BuildContext context, Object error, StackTrace? stack);

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final ErrorBuilder? builder;

  const ErrorBoundary({super.key, required this.child, this.builder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _error = details.exception;
      _stack = details.stack;
      setState(() {});
      return const SizedBox.shrink();
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.builder != null) {
        return widget.builder!(context, _error!, _stack);
      }
      return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.bodyMedium));
    }
    return widget.child;
  }
}

