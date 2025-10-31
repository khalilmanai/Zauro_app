import 'package:json_annotation/json_annotation.dart';

part 'wallet_models.g.dart';

// Main Wallet Model that matches API response
@JsonSerializable()
class Wallet {
  final String id;
  final String hederaAccountId;
  final String publicKey;
  final WalletBalance? balance;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Wallet({
    required this.id,
    required this.hederaAccountId,
    required this.publicKey,
    this.balance,
    required this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  @override
  String toString() {
    return 'Wallet(id: $id, hederaAccountId: $hederaAccountId, publicKey: $publicKey, balance: $balance)';
  }
}

// Wallet Balance Model
@JsonSerializable()
class WalletBalance {
  final String hbar;
  final String zau;
  final Map<String, dynamic>? tokens;
  final String? timestamp;

  const WalletBalance({
    required this.hbar,
    required this.zau,
    this.tokens,
    this.timestamp,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);

  double get hbarBalance {
    final cleanHbar = hbar.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    return double.tryParse(cleanHbar) ?? 0.0;
  }

  double get zauBalance {
    final cleanZau = zau.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    return double.tryParse(cleanZau) ?? 0.0;
  }

  double get totalBalance => hbarBalance + zauBalance;

  String get displayHbar => hbarBalance.toStringAsFixed(2);
  String get displayZau => zauBalance.toStringAsFixed(2);
  String get formattedHbarBalance => '${hbarBalance.toStringAsFixed(2)} HBAR';
  String get formattedZauBalance => '${zauBalance.toStringAsFixed(2)} ZAU';
}

// Transaction Model
@JsonSerializable()
class Transaction {
  final String id;
  final String walletId;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final String? fromAddress;
  final String? toAddress;
  final String? transactionHash;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  const Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.fromAddress,
    this.toAddress,
    this.transactionHash,
    required this.createdAt,
    this.confirmedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  String get displayType {
    switch (type) {
      case 'SEND':
        return 'Sent';
      case 'RECEIVE':
        return 'Received';
      case 'TRADE':
        return 'Trade';
      case 'NFT_MINT':
        return 'NFT Minted';
      case 'NFT_TRANSFER':
        return 'NFT Transfer';
      default:
        return type;
    }
  }

  String get formattedAmount {
    final sign = type == 'SEND' ? '-' : '+';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  // Added for UI compatibility in transaction history
  bool get isIncoming => type == 'RECEIVE';
  String get displayStatus => status;
}

// Request/Response Models
@JsonSerializable()
class CreateWalletRequest {
  final String? userId;

  const CreateWalletRequest({this.userId});

  factory CreateWalletRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWalletRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateWalletRequestToJson(this);
}

@JsonSerializable()
class TransferHbarRequest {
  final String toAccountId;
  final String amount;

  const TransferHbarRequest({
    required this.toAccountId,
    required this.amount,
  });

  factory TransferHbarRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferHbarRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransferHbarRequestToJson(this);
}

@JsonSerializable()
class TransferResponse {
  final String transactionHash;

  const TransferResponse({required this.transactionHash});

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}

@JsonSerializable()
class FundAccountRequest {
  final String? accountId;
  final String amount;
  final String? memo;

  const FundAccountRequest({
    this.accountId,
    required this.amount,
    this.memo,
  });

  factory FundAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$FundAccountRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FundAccountRequestToJson(this);
}
