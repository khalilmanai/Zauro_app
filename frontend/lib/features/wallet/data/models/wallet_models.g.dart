// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
      id: json['id'] as String,
      hederaAccountId: json['hederaAccountId'] as String,
      publicKey: json['publicKey'] as String,
      balance: json['balance'] == null
          ? null
          : WalletBalance.fromJson(json['balance'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'id': instance.id,
      'hederaAccountId': instance.hederaAccountId,
      'publicKey': instance.publicKey,
      'balance': instance.balance,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) =>
    WalletBalance(
      hbar: json['hbar'] as String,
      zau: json['zau'] as String,
      tokens: json['tokens'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$WalletBalanceToJson(WalletBalance instance) =>
    <String, dynamic>{
      'hbar': instance.hbar,
      'zau': instance.zau,
      'tokens': instance.tokens,
      'timestamp': instance.timestamp,
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      fromAddress: json['fromAddress'] as String?,
      toAddress: json['toAddress'] as String?,
      transactionHash: json['transactionHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'description': instance.description,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'transactionHash': instance.transactionHash,
      'createdAt': instance.createdAt.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
    };

CreateWalletRequest _$CreateWalletRequestFromJson(Map<String, dynamic> json) =>
    CreateWalletRequest(
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$CreateWalletRequestToJson(
        CreateWalletRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };

TransferHbarRequest _$TransferHbarRequestFromJson(Map<String, dynamic> json) =>
    TransferHbarRequest(
      toAccountId: json['toAccountId'] as String,
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$TransferHbarRequestToJson(
        TransferHbarRequest instance) =>
    <String, dynamic>{
      'toAccountId': instance.toAccountId,
      'amount': instance.amount,
    };

TransferResponse _$TransferResponseFromJson(Map<String, dynamic> json) =>
    TransferResponse(
      transactionHash: json['transactionHash'] as String,
    );

Map<String, dynamic> _$TransferResponseToJson(TransferResponse instance) =>
    <String, dynamic>{
      'transactionHash': instance.transactionHash,
    };

FundAccountRequest _$FundAccountRequestFromJson(Map<String, dynamic> json) =>
    FundAccountRequest(
      accountId: json['accountId'] as String?,
      amount: json['amount'] as String,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$FundAccountRequestToJson(FundAccountRequest instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'amount': instance.amount,
      'memo': instance.memo,
    };
