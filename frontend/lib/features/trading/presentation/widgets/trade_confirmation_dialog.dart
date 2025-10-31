import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/zauro_snackbar.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/trade_models.dart';
import '../../data/repositories/trading_repository.dart';
import '../../providers/trading_provider.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TradeConfirmationDialog extends ConsumerStatefulWidget {
  final Trade trade;
  const TradeConfirmationDialog({super.key, required this.trade});

  @override
  ConsumerState<TradeConfirmationDialog> createState() => _TradeConfirmationDialogState();
}

class _TradeConfirmationDialogState extends ConsumerState<TradeConfirmationDialog> {
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider).value;
    final balanceHbar = walletBalance?.hbarBalance ?? 0.0;
    final price = widget.trade.price;
    final insufficient = balanceHbar < price;
    final currentUser = ref.read(authNotifierProvider).user;
    final buyingOwn = currentUser != null && widget.trade.sellerId == currentUser.id;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Purchase', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
            const SizedBox(height: 12),
            _row('Animal', widget.trade.animal?.name ?? '—'),
            _row('Seller', _formatSellerName()),
            _row('Price', '${widget.trade.price} ${widget.trade.currency}'),
            _row('Your Balance', '${balanceHbar.toStringAsFixed(2)} HBAR'),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.errorColor)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_submitting || insufficient || buyingOwn) ? null : _confirm,
                    icon: _submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                    label: Text(
                      insufficient
                          ? 'Insufficient funds'
                          : buyingOwn
                              ? 'Cannot buy own'
                              : 'Confirm',
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatSellerName() {
    final seller = widget.trade.seller;
    if (seller?.firstName != null) {
      return '@${seller!.firstName}';
    }
    if (widget.trade.sellerId.isNotEmpty) {
      return widget.trade.sellerId.length > 8 
          ? '${widget.trade.sellerId.substring(0, 8)}...' 
          : widget.trade.sellerId;
    }
    return '—';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.getMutedTextColor(context))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    try {
      setState(() {
        _submitting = true;
        _error = null;
      });
      
      final repo = ref.read(tradingRepositoryProvider);
      final currentUser = ref.read(authNotifierProvider).user;
      
      // Validate buyer != seller
      if (currentUser != null && widget.trade.sellerId == currentUser.id) {
        setState(() {
          _error = 'You cannot buy your own animal.';
          _submitting = false;
        });
        return;
      }

      // Buy then execute
      final bought = await repo.buyAnimal(widget.trade.id);
      await repo.executeTrade(bought.id);
      
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ZauroSnackbar.showSuccess(context, 'Trade completed successfully!');
      
      // Navigate back to marketplace and refresh
      if (context.mounted) {
        // Refresh marketplace provider
        ref.read(marketplaceProvider.notifier).refresh();
        // Navigate to marketplace if not already there
        final currentRoute = GoRouterState.of(context).uri.path;
        if (!currentRoute.contains('/marketplace')) {
          context.go('/marketplace');
        }
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Something went wrong. Please try again.';
      
      if (e is ServerFailure) {
        final code = e.code ?? '';
        if (code.contains('400') || e.message.toLowerCase().contains('400')) {
          errorMessage = 'Invalid request. Please check your input.';
        } else if (code.contains('401') || e.message.toLowerCase().contains('401')) {
          errorMessage = 'Please log in again.';
        } else if (code.contains('500') || e.message.toLowerCase().contains('500')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = e.message;
        }
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid request. Please check your input.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Please log in again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ServerFailure: ', '');
      }
      
      setState(() {
        _error = errorMessage;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
