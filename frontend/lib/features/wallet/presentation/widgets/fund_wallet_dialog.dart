import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../data/models/wallet_models.dart';

class FundWalletDialog extends ConsumerStatefulWidget {
  final WalletResponse wallet;
  final VoidCallback onFundComplete;

  const FundWalletDialog({
    super.key,
    required this.wallet,
    required this.onFundComplete,
  });

  @override
  ConsumerState<FundWalletDialog> createState() => _FundWalletDialogState();
}

class _FundWalletDialogState extends ConsumerState<FundWalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  bool _isLoading = false;
  String? _transactionHash;
  bool _success = false;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
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
        child: _success ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
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
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fund Wallet',
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

          // Account Info
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
                  'Account ID',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.getMutedTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.wallet.hederaAccountId,
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.white : AppTheme.grey900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount
          Text(
            'Amount (HBAR)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _amountController,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateAmount,
            prefixIcon: Icons.monetization_on,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
            ],
          ),

          const SizedBox(height: 16),

          // Memo (Optional)
          Text(
            'Memo (Optional)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _memoController,
            hint: 'Add a note...',
            maxLines: 2,
            prefixIcon: Icons.note_outlined,
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
                  onPressed: _isLoading ? null : _fundWallet,
                  text: 'Fund Wallet',
                  isLoading: _isLoading,
                  backgroundColor: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: AppTheme.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Wallet Funded Successfully!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.white : AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your wallet has been funded with ${_amountController.text} HBAR',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.getMutedTextColor(context),
          ),
        ),
        if (_transactionHash != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.grey800 : AppTheme.grey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Hash',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.getMutedTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transactionHash!,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: isDark ? AppTheme.white : AppTheme.grey900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        CustomButton(
          onPressed: () {
            widget.onFundComplete();
            Navigator.of(context).pop();
          },
          text: 'Done',
          backgroundColor: AppTheme.success,
        ),
      ],
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }

    return null;
  }

  Future<void> _fundWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = FundAccountRequest(
        amount: _amountController.text.trim(),
        memo: _memoController.text.isNotEmpty
            ? _memoController.text.trim()
            : null,
      );

      final response = await ref.read(apiClientProvider).fundMyAccount(request);

      if (mounted && response.success && response.data != null) {
        setState(() {
          _transactionHash = response.data!.transactionHash;
          _success = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funding failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
