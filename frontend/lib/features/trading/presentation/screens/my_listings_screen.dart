import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/zauro_snackbar.dart';
import '../../../animals/data/models/animal_models.dart';
import '../../../animals/providers/animals_provider.dart';
import '../../data/models/trade_models.dart';
import '../../data/repositories/trading_repository.dart';
import '../../providers/trading_provider.dart';
import '../widgets/status_badge.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myTradesProvider.notifier).getMyTrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myTradesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openListNewDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: state.when(
        data: (trades) => _buildContent(context, trades),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load listings')), 
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Trade> trades) {
    final listed = trades.where((t) => t.status == 'LISTED').toList();
    final pending = trades.where((t) => t.status == 'PENDING').toList();
    final completed = trades.where((t) => t.status == 'COMPLETED').toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(myTradesProvider.notifier).getMyTrades(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Listed Animals', listed, actionBuilder: (t) => TextButton(
                onPressed: () => _cancelTrade(t),
                child: const Text('Cancel'),
              )),
          const SizedBox(height: 16),
          _section('Pending Trades', pending,               actionBuilder: (t) => TextButton(
                onPressed: () => context.push('/animals/${t.animalId}'),
                child: const Text('View Details'),
              )),
          const SizedBox(height: 16),
          _section('Completed Trades', completed,               actionBuilder: (t) => TextButton(
                onPressed: () => context.push('/animals/${t.animalId}'),
                child: const Text('View Details'),
              )),
        ],
      ),
    );
  }

  Widget _section(String title, List<Trade> trades, {Widget Function(Trade)? actionBuilder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColorFromContext(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (trades.isEmpty)
              Text('No items', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context)))
            else
              ...trades.map((t) => _tradeRow(t, actionBuilder)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _tradeRow(Trade t, Widget Function(Trade)? actionBuilder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: t.animal?.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(t.animal!.imageUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.pets_rounded, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.animal?.name ?? 'Animal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                    StatusBadge(status: t.status, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${t.price} ${t.currency}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.getMutedTextColor(context))),
              ],
            ),
          ),
          if (actionBuilder != null) actionBuilder(t),
        ],
      ),
    );
  }

  Future<void> _cancelTrade(Trade t) async {
    try {
      final repo = ref.read(tradingRepositoryProvider);
      await repo.cancelTrade(t.id);
      if (!mounted) return;
      ZauroSnackbar.showSuccess(context, 'Listing cancelled successfully');
      await ref.read(myTradesProvider.notifier).getMyTrades();
    } catch (e) {
      if (!mounted) return;
      ZauroSnackbar.showError(context, 'Failed to cancel listing: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> _openListNewDialog() async {
    await ref.read(animalsProvider.notifier).getAnimals(ownerId: 'me');
    if (!mounted) return;

    final animals = ref.read(animalsProvider).value ?? [];
    Animal? selected;
    final priceController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('List New Animal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Animal>(
              value: selected,
              items: animals
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                  .toList(),
              onChanged: (v) => selected = v,
              decoration: const InputDecoration(labelText: 'Animal'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (HBAR)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('List')),
        ],
      ),
    );

    if (confirmed == true && selected != null) {
      try {
        final price = double.tryParse(priceController.text.trim());
        if (price == null) throw Exception('Invalid price');
        final repo = ref.read(tradingRepositoryProvider);
        await repo.createTrade(CreateTradeRequest(
          animalId: selected!.id,
          price: price,
          currency: 'HBAR',
        ));
        if (!mounted) return;
        ZauroSnackbar.showSuccess(context, 'Animal listed successfully');
        await ref.read(myTradesProvider.notifier).getMyTrades();
      } catch (e) {
        if (!mounted) return;
        ZauroSnackbar.showError(context, 'Failed to list animal: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }
  }
}
