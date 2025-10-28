import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../animals/data/models/animal_models.dart';
import '../../../trading/providers/trading_provider.dart';
import '../../../trading/data/models/trade_models.dart';

class ListNftDialog extends ConsumerStatefulWidget {
  final Animal nft;
  final VoidCallback onListed;

  const ListNftDialog({
    super.key,
    required this.nft,
    required this.onListed,
  });

  @override
  ConsumerState<ListNftDialog> createState() => _ListNftDialogState();
}

class _ListNftDialogState extends ConsumerState<ListNftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  bool _isLoading = false;
  String _selectedCurrency = 'HBAR';

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.grey900 : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.sell_outlined,
                      color: AppTheme.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'List NFT for Sale',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.grey900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppTheme.white : AppTheme.grey900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // NFT Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.grey800 : AppTheme.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NFT',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.getMutedTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.nft.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.grey900,
                      ),
                    ),
                    if (widget.nft.tokenSerialNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Token #${widget.nft.tokenSerialNumber}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Currency Selection
              Text(
                'Currency',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCurrencyButton('HBAR'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCurrencyButton('ZAU'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price
              Text(
                'Listing Price',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      hint: '0.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePrice,
                      prefixIcon: Icons.monetization_on,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,8}')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedCurrency,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once listed, your NFT will be visible to all users. You can cancel the listing at any time.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _listNFT,
                      text: 'List NFT',
                      isLoading: _isLoading,
                      backgroundColor: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyButton(String currency) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedCurrency == currency;

    return InkWell(
      onTap: () => setState(() => _selectedCurrency = currency),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppTheme.grey800 : AppTheme.grey50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? AppTheme.grey700 : AppTheme.grey200),
            width: 2,
          ),
        ),
        child: Text(
          currency,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.getTextColor(context),
          ),
        ),
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter price';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }

    return null;
  }

  Future<void> _listNFT() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create trade request
      final request = CreateTradeRequest(
        animalId: widget.nft.id,
        price: double.parse(_priceController.text.trim()),
        currency: _selectedCurrency,
      );

      // Call API through trading provider
      await ref.read(myTradesProvider.notifier).createTrade(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('NFT listed successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        widget.onListed();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
