import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../data/models/wallet_models.dart';
import '../../providers/wallet_provider.dart';

class TransferHbarDialog extends ConsumerStatefulWidget {
  final WalletResponse wallet;
  final VoidCallback onTransferComplete;

  const TransferHbarDialog({
    super.key,
    required this.wallet,
    required this.onTransferComplete,
  });

  @override
  ConsumerState<TransferHbarDialog> createState() => _TransferHbarDialogState();
}

class _TransferHbarDialogState extends ConsumerState<TransferHbarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.white,
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
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Send HBAR',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Current Balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, child) {
                        final balance = ref.watch(walletBalanceProvider);
                        return balance.when(
                          data: (data) => Text(
                            data?.formattedHbarBalance ?? '0.00000000 HBAR',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.grey900,
                            ),
                          ),
                          loading: () => Text(
                            'Loading...',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.grey900,
                            ),
                          ),
                          error: (_, __) => Text(
                            'Error loading balance',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Recipient Account ID
              Text(
                'Recipient Account ID',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey700,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _toAccountController,
                hintText: '0.0.123456',
                keyboardType: TextInputType.text,
                validator: _validateAccountId,
                prefixIcon: Icons.account_balance_wallet,
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              Text(
                'Amount (HBAR)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey700,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _amountController,
                hintText: '0.00000000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                prefixIcon: Icons.monetization_on,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _transferHbar,
                      text: 'Send HBAR',
                      isLoading: _isLoading,
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

  String? _validateAccountId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter recipient account ID';
    }
    
    // Validate Hedera account ID format (0.0.123456)
    final regex = RegExp(r'^0\.0\.[0-9]+$');
    if (!regex.hasMatch(value)) {
      return 'Invalid account ID format (use 0.0.123456)';
    }
    
    // Can't send to self
    if (value == widget.wallet.hederaAccountId) {
      return 'Cannot send to your own account';
    }
    
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    
    // Check against available balance
    final balance = ref.read(walletBalanceProvider).value;
    if (balance != null && amount > balance.hbarBalance) {
      return 'Insufficient balance';
    }
    
    return null;
  }

  Future<void> _transferHbar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(transferProvider.notifier).transferHbar(
        toAccountId: _toAccountController.text.trim(),
        amount: _amountController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HBAR transfer initiated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        widget.onTransferComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: $e'),
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
