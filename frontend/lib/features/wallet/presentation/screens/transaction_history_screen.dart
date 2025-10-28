import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/wallet_models.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Transaction> _mockTransactions = [
    // Mock data - will be replaced with real data from API
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppTheme.getTextColor(context),
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.getMutedTextColor(context),
          labelStyle: GoogleFonts.poppins(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
            Tab(text: 'Trades'),
            Tab(text: 'NFTs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsList('ALL', isTablet, isDark),
          _buildTransactionsList('SEND', isTablet, isDark),
          _buildTransactionsList('RECEIVE', isTablet, isDark),
          _buildTransactionsList('TRADE', isTablet, isDark),
          _buildTransactionsList('NFT', isTablet, isDark),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(String filter, bool isTablet, bool isDark) {
    final filteredTransactions = _mockTransactions.where((tx) {
      if (filter == 'ALL') return true;
      if (filter == 'NFT') {
        return tx.type.contains('NFT');
      }
      return tx.type == filter;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState(isTablet, isDark);
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      color: AppTheme.primaryColor,
      child: ListView.separated(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        itemCount: filteredTransactions.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: isTablet ? 12 : 10),
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return _buildTransactionCard(transaction, isTablet, isDark);
        },
      ),
    );
  }

  Widget _buildTransactionCard(
      Transaction transaction, bool isTablet, bool isDark) {
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    IconData icon;
    Color iconColor;

    switch (transaction.type) {
      case 'SEND':
        icon = Icons.arrow_upward_rounded;
        iconColor = AppTheme.errorColor;
        break;
      case 'RECEIVE':
        icon = Icons.arrow_downward_rounded;
        iconColor = AppTheme.success;
        break;
      case 'TRADE':
        icon = Icons.swap_horiz_rounded;
        iconColor = AppTheme.warning;
        break;
      case 'NFT_MINT':
        icon = Icons.auto_awesome_rounded;
        iconColor = AppTheme.primaryColor;
        break;
      case 'NFT_TRANSFER':
        icon = Icons.image_rounded;
        iconColor = AppTheme.info;
        break;
      default:
        icon = Icons.receipt_rounded;
        iconColor = AppTheme.getMutedTextColor(context);
    }

    return InkWell(
      onTap: () => _showTransactionDetails(transaction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: isTablet ? 24 : 22,
              ),
            ),

            SizedBox(width: isTablet ? 14 : 12),

            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.displayType,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      Text(
                        transaction.formattedAmount,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: transaction.isIncoming
                              ? AppTheme.success
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 4 : 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(transaction.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 13 : 12,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                      _buildStatusChip(transaction.displayStatus, isTablet),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isTablet) {
    Color color;
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        color = AppTheme.success;
        break;
      case 'PENDING':
        color = AppTheme.warning;
        break;
      case 'FAILED':
        color = AppTheme.errorColor;
        break;
      default:
        color = AppTheme.getMutedTextColor(context);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: isTablet ? 11 : 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: isTablet ? 80 : 64,
            color: AppTheme.getMutedTextColor(context).withOpacity(0.3),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getMutedTextColor(context),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : 13,
              color: AppTheme.getMutedTextColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.grey900 : AppTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.getTextColor(context),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            _buildDetailRow('Type', transaction.displayType),
            _buildDetailRow('Amount', transaction.formattedAmount),
            _buildDetailRow('Status', transaction.displayStatus),
            _buildDetailRow('Date', _formatDateFull(transaction.createdAt)),
            if (transaction.fromAddress != null)
              _buildDetailRow('From', transaction.fromAddress!, copyable: true),
            if (transaction.toAddress != null)
              _buildDetailRow('To', transaction.toAddress!, copyable: true),
            if (transaction.transactionHash != null)
              _buildDetailRow('Hash', transaction.transactionHash!,
                  copyable: true),
            if (transaction.description != null)
              _buildDetailRow('Description', transaction.description!),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getMutedTextColor(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextColor(context),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: copyable ? 2 : 1,
                    overflow:
                        copyable ? TextOverflow.ellipsis : TextOverflow.clip,
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied!'),
                          backgroundColor: AppTheme.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // TODO: Implement filter bottom sheet with date range, amount range, etc.
  }

  Future<void> _refreshTransactions() async {
    // TODO: Implement refresh from API
    await Future.delayed(const Duration(seconds: 1));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatDateFull(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}
