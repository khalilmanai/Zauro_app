// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) => Collection(
      id: json['id'] as String,
      tokenId: json['tokenId'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      memo: json['memo'] as String?,
      maxSupply: (json['maxSupply'] as num?)?.toInt(),
      currentSupply: (json['currentSupply'] as num).toInt(),
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CollectionToJson(Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tokenId': instance.tokenId,
      'name': instance.name,
      'symbol': instance.symbol,
      'memo': instance.memo,
      'maxSupply': instance.maxSupply,
      'currentSupply': instance.currentSupply,
      'isDefault': instance.isDefault,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateCollectionRequest _$CreateCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCollectionRequest(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      memo: json['memo'] as String?,
      maxSupply: (json['maxSupply'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$CreateCollectionRequestToJson(
        CreateCollectionRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'memo': instance.memo,
      'maxSupply': instance.maxSupply,
      'isDefault': instance.isDefault,
    };

RotateCollectionRequest _$RotateCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    RotateCollectionRequest(
      namePrefix: json['namePrefix'] as String?,
      symbolPrefix: json['symbolPrefix'] as String?,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$RotateCollectionRequestToJson(
        RotateCollectionRequest instance) =>
    <String, dynamic>{
      'namePrefix': instance.namePrefix,
      'symbolPrefix': instance.symbolPrefix,
      'memo': instance.memo,
    };

CollectionsResponse _$CollectionsResponseFromJson(Map<String, dynamic> json) =>
    CollectionsResponse(
      collections: (json['collections'] as List<dynamic>)
          .map((e) => Collection.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$CollectionsResponseToJson(
        CollectionsResponse instance) =>
    <String, dynamic>{
      'collections': instance.collections,
      'total': instance.total,
    };
