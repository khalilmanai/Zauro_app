import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../data/models/animal_models.dart';
import '../../providers/animals_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../trading/data/repositories/trading_repository.dart';
import '../../../trading/data/models/trade_models.dart';
import '../../../trading/presentation/widgets/trade_confirmation_dialog.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalProvider(widget.animalId));
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Animal Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push('/animals/${widget.animalId}/edit');
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Animal'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Animal',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isUploading || animalState.isLoading,
        child: animalState.when(
          data: (animal) => _buildContent(animal),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(context, e),
        ),
      ),
    );
  }

  Widget _buildBuyOrOwnerActions(Animal animal) {
    final auth = ref.watch(authNotifierProvider);
    final myId = auth.user?.id;
    final isOwner = myId != null && myId == animal.ownerId;
    final isBuyable = !isOwner && animal.isListed == true;

    // Show buy button for non-owners when listed
    if (isBuyable) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isUploading ? null : () => _buyAnimal(animal.id),
          icon: const Icon(Icons.shopping_cart_checkout_rounded),
          label: Text(
            'Buy Now',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _cancelListing(String animalId) async {
    try {
      setState(() => _isUploading = true);
      final tradingRepo = ref.read(tradingRepositoryProvider);
      // Find listed trade for this animal
      final tradesForAnimal = await tradingRepo.getTradesByAnimal(animalId);
      final listed = tradesForAnimal.firstWhere(
        (t) => t.status == 'LISTED' || t.status == 'ACTIVE',
        orElse: () =>
            throw Exception('No active listing found for this animal'),
      );
      await tradingRepo.cancelTrade(listed.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Listing cancelled successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Refresh animal details
      await ref.read(animalProvider(widget.animalId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel listing: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _buyAnimal(String animalId) async {
    try {
      setState(() => _isUploading = true);
      final tradingRepo = ref.read(tradingRepositoryProvider);
      // Find listed trade for this animal
      final tradesForAnimal = await tradingRepo.getTradesByAnimal(animalId);
      final listed = tradesForAnimal.firstWhere(
        (t) => t.status == 'LISTED',
        orElse: () =>
            throw Exception('No active listing found for this animal'),
      );
      if (!mounted) return;
      final result = await showDialog(
        context: context,
        builder: (ctx) => TradeConfirmationDialog(trade: listed),
      );
      if (result == true) {
        // Refresh current animal (ownership/listing might change)
        await ref.read(animalProvider(widget.animalId).notifier).refresh();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final message = error.toString();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'Failed to load animal',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.grey600),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(animalProvider(widget.animalId).notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Animal? animal) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(animal),
          _buildInfoSection(animal),
          _buildNFTSection(animal),
          _buildActionsSection(animal),
        ],
      ),
    );
  }

  Widget _buildImageSection(Animal? animal) {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppTheme.grey200,
      child: animal?.imageUrl != null
          ? Image.network(animal!.imageUrl!, fit: BoxFit.cover)
          : Center(
              child: Icon(Icons.pets, size: 80, color: AppTheme.grey400),
            ),
    );
  }

  Widget _buildInfoSection(Animal? animal) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            animal?.name ?? 'Animal',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip('Species', animal?.species ?? '—'),
              if (animal?.breed != null)
                _buildInfoChip('Breed', animal!.breed!),
              _buildInfoChip(
                'Age',
                animal?.age == null
                    ? '—'
                    : animal!.age == 1
                        ? '1 year'
                        : '${animal.age} years',
              ),
              _buildInfoChip('Gender', animal?.gender ?? '—'),
              _buildInfoChip('Listed', animal?.isListed == true ? 'Yes' : 'No'),
              if (animal?.reviewStatus != null)
                _buildInfoChip('Status', animal!.reviewStatus!.displayName),
              _buildInfoChip(
                'Created',
                animal?.createdAt != null
                    ? _formatDate(animal!.createdAt)
                    : '—',
              ),
              if (animal?.owner != null)
                _buildInfoChip('Owner', animal!.owner!.fullName),
              if (animal?.owner?.email != null)
                _buildInfoChip('Owner Email', animal!.owner!.email),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            animal?.description ?? 'No description provided.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.grey700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // yyyy-MM-dd HH:mm
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Widget _buildNFTSection(Animal? animal) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.verified,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NFT Status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey900,
                      ),
                    ),
                    Text(
                      'Minted on Hedera Hashgraph',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildNFTInfo('Token ID', animal?.tokenId ?? '—'),
          SizedBox(height: 8),
          _buildNFTInfo('Serial Number', animal?.tokenSerialNumber ?? '—'),
          SizedBox(height: 8),
          _buildNFTInfo('AI Valuation',
              animal?.aiPredictionValue?.toStringAsFixed(2) ?? '—'),
        ],
      ),
    );
  }

  Widget _buildNFTInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.grey600),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(Animal? animal) {
    if (animal == null) return const SizedBox.shrink();

    final auth = ref.read(authNotifierProvider);
    final myId = auth.user?.id;
    final isOwner = myId != null && myId == animal.ownerId;
    final isApproved = animal.reviewStatus == AnimalStatus.expertApproved;
    final isMinted = animal.tokenId != null && animal.tokenId!.isNotEmpty;
    final hasVetRecord =
        animal.vetRecordUrl != null && animal.vetRecordUrl!.isNotEmpty;
    final hasImage = animal.imageUrl != null && animal.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBuyOrOwnerActions(animal),
          if (isOwner) ...[
            const SizedBox(height: 12),
            // Mint NFT button - show if approved but not minted
            if (isApproved && !isMinted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _mintAnimal(animal.id),
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.autorenew),
                  label: Text(
                    'Mint NFT',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            // Cancel listing button - show if listed
            if (animal.isListed == true)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isUploading ? null : () => _cancelListing(animal.id),
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cancel_outlined),
                  label: Text(
                    'Cancel Animal Sale',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppTheme.errorColor, width: 2),
                  ),
                ),
              )
            // List for Trade button - show if approved and not listed
            else if (isApproved && _shouldShowListButton(animal))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () => _showListForTradeDialog(animal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'List for Trade',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndUploadImage(),
                    icon: Icon(
                        hasImage ? Icons.add_photo_alternate : Icons.upload),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      hasImage ? 'Add More Images' : 'Upload Image',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndUploadVetRecord(),
                    icon: Icon(
                        hasVetRecord ? Icons.edit_document : Icons.upload_file),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      hasVetRecord ? 'Update Vet Record' : 'Vet Records',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Animal'),
        content: Text(
          'Are you sure you want to delete this animal? This action cannot be undone and will burn the NFT.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await _deleteAnimal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnimal() async {
    try {
      setState(() => _isUploading = true);
      await ref.read(animalProvider(widget.animalId).notifier).deleteAnimal();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Animal deleted successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Navigate back after deletion
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to delete animal: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('ServerFailure: ', '')}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      setState(() => _isUploading = true);
      await ref.read(animalProvider(widget.animalId).notifier).uploadImage(
            File(picked.path),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
      // Refresh to update UI
      await ref.read(animalProvider(widget.animalId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadVetRecord() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
      if (result == null || result.files.single.path == null) return;
      setState(() => _isUploading = true);
      await ref
          .read(animalProvider(widget.animalId).notifier)
          .uploadVetRecord(File(result.files.single.path!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vet record uploaded successfully')),
      );
      // Refresh to update UI
      await ref.read(animalProvider(widget.animalId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vet record upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  bool _shouldShowListButton(Animal animal) {
    final auth = ref.read(authNotifierProvider);
    final myId = auth.user?.id;
    final isOwner = myId != null && myId == animal.ownerId;
    final isApproved = animal.reviewStatus == AnimalStatus.expertApproved;
    // Show button if user owns the animal, it's approved, and not already listed
    return isOwner && isApproved && animal.isListed != true;
  }

  Future<void> _mintAnimal(String animalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Mint NFT',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will mint the animal as an NFT on the Hedera blockchain. This action cannot be undone. Continue?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text(
              'Mint',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isUploading = true);
      await ref.read(animalProvider(animalId).notifier).mintAnimal();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('NFT minted successfully on Hedera blockchain'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
      // Refresh animal details to show NFT info
      await ref.read(animalProvider(widget.animalId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ServerFailure: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mint NFT: $errorMessage'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showListForTradeDialog(Animal animal) async {
    final priceController = TextEditingController(
      text: animal.aiPredictionValue?.toStringAsFixed(2) ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'List for Trade',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the price for ${animal.name}:',
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.grey700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price (HBAR)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: animal.aiPredictionValue != null
                    ? 'AI Suggested: ${animal.aiPredictionValue!.toStringAsFixed(2)} HBAR'
                    : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text.trim());
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price')),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              'List',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price entered')),
      );
      return;
    }

    try {
      setState(() => _isUploading = true);
      final tradingRepo = ref.read(tradingRepositoryProvider);
      await tradingRepo.createTrade(
        CreateTradeRequest(
          animalId: animal.id,
          price: price,
          currency: 'HBAR',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Animal listed for trade successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Refresh animal details to update isListed status
      await ref.read(animalProvider(widget.animalId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to list animal: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('ServerFailure: ', '')}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}
