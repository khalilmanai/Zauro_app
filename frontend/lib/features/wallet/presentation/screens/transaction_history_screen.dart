import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../trading/data/models/trade_models.dart';
import '../../../trading/data/repositories/trading_repository.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  AsyncValue<List<Trade>> _state = const AsyncValue.loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncValue.loading());
    try {
      final repo = ref.read(tradingRepositoryProvider);
      final trades = await repo.getTradeHistory();
      if (!mounted) return;
      setState(() => _state = AsyncValue.data(trades));
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _state = AsyncValue.error(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _state.when(
          data: (trades) => trades.isEmpty ? _buildEmpty(context) : _buildList(context, trades),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(context, e),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Trade> trades) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trades.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = trades[index];
        return Container
          (
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getCardBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColorFromContext(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppTheme.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.animal?.name ?? 'Animal',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.price} ${t.currency} • ${t.status}',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.getMutedTextColor(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.getMutedTextColor(context).withOpacity(0.6)),
              const SizedBox(height: 12),
              Text('No transactions yet', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Your completed trades will appear here', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object e) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text('Failed to load history', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(e.toString(), style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              )
            ],
          ),
        ),
      ],
    );
  }
}
