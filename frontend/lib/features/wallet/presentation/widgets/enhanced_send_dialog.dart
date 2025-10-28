import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../data/models/wallet_models.dart';
import '../../providers/wallet_provider.dart';
import 'qr_scanner_widget.dart';

class EnhancedSendDialog extends ConsumerStatefulWidget {
  final WalletResponse wallet;
  final VoidCallback onTransferComplete;

  const EnhancedSendDialog({
    super.key,
    required this.wallet,
    required this.onTransferComplete,
  });

  @override
  ConsumerState<EnhancedSendDialog> createState() => _EnhancedSendDialogState();
}

class _EnhancedSendDialogState extends ConsumerState<EnhancedSendDialog> {
  final _formKey = GlobalKey<FormState>();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  final _biometricAuth = BiometricAuthService();

  bool _isLoading = false;
  String _selectedAsset = 'HBAR';

  @override
  void dispose() {
    _toAccountController.dispose();
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
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.grey900 : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Send $_selectedAsset',
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

                // Asset Selection
                Text(
                  'Select Asset',
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
                      child: _buildAssetButton('HBAR', Icons.currency_bitcoin),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAssetButton('ZAU', Icons.toll_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Current Balance
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
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final balance = ref.watch(walletBalanceProvider);
                          return balance.when(
                            data: (data) => Text(
                              _selectedAsset == 'HBAR'
                                  ? (data?.formattedHbarBalance ?? '0.00 HBAR')
                                  : (data?.formattedZauBalance ?? '0.00 ZAU'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? AppTheme.white : AppTheme.grey900,
                              ),
                            ),
                            loading: () => Text(
                              'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? AppTheme.white : AppTheme.grey900,
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
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _toAccountController,
                        hint: '0.0.123456',
                        keyboardType: TextInputType.text,
                        validator: _validateAccountId,
                        prefixIcon: Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: _scanQrCode,
                        tooltip: 'Scan QR Code',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Amount
                Text(
                  'Amount ($_selectedAsset)',
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateAmount,
                  prefixIcon: Icons.monetization_on,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,8}')),
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

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: AppTheme.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This transaction requires biometric confirmation',
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
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
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
                        onPressed: _isLoading ? null : _sendWithBiometric,
                        text: 'Send $_selectedAsset',
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetButton(String asset, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedAsset == asset;

    return InkWell(
      onTap: () => setState(() => _selectedAsset = asset),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.getTextColor(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              asset,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQrCode() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScannerWidget(
          title: 'Scan Recipient QR Code',
          onScanned: (code) {
            setState(() {
              _toAccountController.text = code;
            });
          },
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
    if (balance != null) {
      final availableBalance =
          _selectedAsset == 'HBAR' ? balance.hbarBalance : balance.zauBalance;
      if (amount > availableBalance) {
        return 'Insufficient balance';
      }
    }

    return null;
  }

  Future<void> _sendWithBiometric() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if ZAU is selected
    if (_selectedAsset == 'ZAU') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'ZAU transfers are currently not supported. Please use HBAR.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Authenticate with biometrics
    final authenticated = await _biometricAuth.authenticate(
      reason:
          'Confirm transaction of ${_amountController.text} $_selectedAsset',
    );

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Authentication failed. Transaction cancelled.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(transferProvider.notifier).transferHbar(
            toAccountId: _toAccountController.text.trim(),
            amount: _amountController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedAsset transfer initiated successfully!'),
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
