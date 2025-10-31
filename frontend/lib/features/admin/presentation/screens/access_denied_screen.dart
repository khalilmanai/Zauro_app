import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('403 - Access Denied', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, size: 64, color: scheme.error),
            const SizedBox(height: 12),
            Text('You do not have permission to view this page', style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

