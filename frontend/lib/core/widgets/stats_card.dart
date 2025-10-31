import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final VoidCallback? onTap;
  const StatsCard({super.key, required this.icon, required this.label, required this.value, this.delta, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: scheme.primaryContainer, child: Icon(icon, color: scheme.onPrimaryContainer)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Row(children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (delta != null) Text(delta!, style: TextStyle(color: scheme.primary, fontSize: 12)),
              ]),
            ]),
          ),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: card);
  }
}


