import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDidsScreen extends StatelessWidget {
  const AdminDidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin • DIDs', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      body: const Center(child: Text('DID management coming soon')),
    );
  }
}

