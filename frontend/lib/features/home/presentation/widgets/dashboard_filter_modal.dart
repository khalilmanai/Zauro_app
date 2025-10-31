import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../trading/providers/trading_provider.dart';

class DashboardFilterModal extends ConsumerStatefulWidget {
  const DashboardFilterModal({super.key});

  @override
  ConsumerState<DashboardFilterModal> createState() => _DashboardFilterModalState();
}

class _DashboardFilterModalState extends ConsumerState<DashboardFilterModal> {
  String? _selectedSpecies;
  String? _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final species = ['All', ...AppConfig.animalSpecies];
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Marketplace',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.grey900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppTheme.grey600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Species',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: species.map((spec) {
                final isSelected = (_selectedSpecies ?? 'All') == spec;
                return FilterChip(
                  label: Text(
                    spec == 'All' ? 'All' : spec.toLowerCase().replaceFirst(
                      spec[0],
                      spec[0].toUpperCase(),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecies = selected ? spec : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Sort By',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text(
                    'Newest First',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  value: 'newest',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Name (A-Z)',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  value: 'name',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Price: Low to High',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  value: 'price_low',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Price: High to Low',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  value: 'price_high',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSpecies = null;
                        _sortBy = 'newest';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/marketplace');
                      // Apply filters after navigation
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (_selectedSpecies != null && _selectedSpecies != 'All') {
                          ref.read(marketplaceProvider.notifier).searchMarketplace(
                            '',
                            species: _selectedSpecies,
                          );
                        } else {
                          ref.read(marketplaceProvider.notifier).getAvailableTrades();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

