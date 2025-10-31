import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';

class WalletCard extends ConsumerWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider).value;
    final balance = ref.watch(walletBalanceProvider).value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColorFromContext(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Wallet', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HBAR Balance', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context))),
                    const SizedBox(height: 4),
                    Text(balance?.displayHbar ?? '--', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wallet?.publicKey ?? '—',
                            style: GoogleFonts.robotoMono(fontSize: 11, color: AppTheme.getMutedTextColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          onPressed: wallet?.publicKey == null
                              ? null
                              : () {
                                  Clipboard.setData(ClipboardData(text: wallet!.publicKey));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Public key copied')));
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (wallet?.publicKey != null)
                InkWell(
                  onTap: () => _showQr(context, wallet!.publicKey),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.getBorderColorFromContext(context)),
                    ),
                    child: QrImageView(
                      data: wallet!.publicKey,
                      version: QrVersions.auto,
                      size: 64,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQr(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Public Key'),
        content: QrImageView(data: data, version: QrVersions.auto, size: 200, backgroundColor: Colors.white),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
