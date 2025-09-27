// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trade _$TradeFromJson(Map<String, dynamic> json) => Trade(
      id: json['id'] as String,
      animalId: json['animalId'] as String,
      sellerId: json['sellerId'] as String,
      buyerId: json['buyerId'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      animal: json['animal'] == null
          ? null
          : TradeAnimal.fromJson(json['animal'] as Map<String, dynamic>),
      seller: json['seller'] == null
          ? null
          : TradeUser.fromJson(json['seller'] as Map<String, dynamic>),
      buyer: json['buyer'] == null
          ? null
          : TradeUser.fromJson(json['buyer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TradeToJson(Trade instance) => <String, dynamic>{
      'id': instance.id,
      'animalId': instance.animalId,
      'sellerId': instance.sellerId,
      'buyerId': instance.buyerId,
      'price': instance.price,
      'currency': instance.currency,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'animal': instance.animal,
      'seller': instance.seller,
      'buyer': instance.buyer,
    };

TradeAnimal _$TradeAnimalFromJson(Map<String, dynamic> json) => TradeAnimal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      tokenId: json['tokenId'] as String?,
    );

Map<String, dynamic> _$TradeAnimalToJson(TradeAnimal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'imageUrl': instance.imageUrl,
      'tokenId': instance.tokenId,
    };

TradeUser _$TradeUserFromJson(Map<String, dynamic> json) => TradeUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$TradeUserToJson(TradeUser instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };

CreateTradeRequest _$CreateTradeRequestFromJson(Map<String, dynamic> json) =>
    CreateTradeRequest(
      animalId: json['animalId'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$CreateTradeRequestToJson(CreateTradeRequest instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'price': instance.price,
      'currency': instance.currency,
    };
