import 'package:json_annotation/json_annotation.dart';

part 'wallet_models.g.dart';

// Wallet Model
@JsonSerializable()
class Wallet {
  final String id;
  final String userId;
  final String hederaAccountId;
  final String publicKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WalletUser? user;

  const Wallet({
    required this.id,
    required this.userId,
    required this.hederaAccountId,
    required this.publicKey,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  Wallet copyWith({
    String? id,
    String? userId,
    String? hederaAccountId,
    String? publicKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    WalletUser? user,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hederaAccountId: hederaAccountId ?? this.hederaAccountId,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

// Wallet User Model
@JsonSerializable()
class WalletUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const WalletUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory WalletUser.fromJson(Map<String, dynamic> json) =>
      _$WalletUserFromJson(json);
  Map<String, dynamic> toJson() => _$WalletUserToJson(this);

  String get fullName => '$firstName $lastName';
}

// Wallet Balance Model - Updated to match backend BalanceResponseDto
@JsonSerializable()
class WalletBalance {
  final String hbar;
  final String zau;

  const WalletBalance({
    required this.hbar,
    required this.zau,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);

  // Convenience getters for backward compatibility
  double get hbarBalance => double.tryParse(hbar) ?? 0.0;
  double get zauBalance => double.tryParse(zau) ?? 0.0;

  WalletBalance copyWith({
    String? hbar,
    String? zau,
  }) {
    return WalletBalance(
      hbar: hbar ?? this.hbar,
      zau: zau ?? this.zau,
    );
  }

  double get totalBalance => hbarBalance + zauBalance;

  String get formattedHbarBalance => '${hbarBalance.toStringAsFixed(8)} HBAR';
  String get formattedZauBalance => '${zauBalance.toStringAsFixed(2)} ZAU';
  String get formattedTotalBalance => totalBalance.toStringAsFixed(8);
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

  Transaction copyWith({
    String? id,
    String? walletId,
    String? type,
    double? amount,
    String? currency,
    String? status,
    String? description,
    String? fromAddress,
    String? toAddress,
    String? transactionHash,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      transactionHash: transactionHash ?? this.transactionHash,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

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

  String get displayStatus {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  String get formattedAmount {
    final sign = type == 'SEND' ? '-' : '+';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  bool get isIncoming => type == 'RECEIVE';
  bool get isOutgoing => type == 'SEND';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
}

// Create Wallet Request - Updated to match backend CreateWalletDto
@JsonSerializable()
class CreateWalletRequest {
  final String? userId; // Optional, ignored by backend

  const CreateWalletRequest({this.userId});

  factory CreateWalletRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWalletRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateWalletRequestToJson(this);
}

// Transfer HBAR Request - New DTO matching backend TransferHbarDto
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

// Transfer Response - New DTO matching backend TransferResponseDto
@JsonSerializable()
class TransferResponse {
  final String transactionHash;

  const TransferResponse({required this.transactionHash});

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}

// Enhanced Wallet Model - Updated to match backend WalletResponseDto
@JsonSerializable()
class WalletResponse {
  final String id;
  final String hederaAccountId;
  final String publicKey;
  final WalletBalance balance;
  final DateTime createdAt;

  const WalletResponse({
    required this.id,
    required this.hederaAccountId,
    required this.publicKey,
    required this.balance,
    required this.createdAt,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WalletResponseToJson(this);
}

// Fund Account Request - New DTO matching backend FundAccountDto
@JsonSerializable()
class FundAccountRequest {
  final String? accountId; // Optional for direct account funding
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

// Legacy Send Transaction Request - Kept for backward compatibility
@JsonSerializable()
class SendTransactionRequest {
  final String toAddress;
  final double amount;
  final String currency;
  final String? description;

  const SendTransactionRequest({
    required this.toAddress,
    required this.amount,
    required this.currency,
    this.description,
  });

  factory SendTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$SendTransactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendTransactionRequestToJson(this);
}
