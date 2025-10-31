// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Animal _$AnimalFromJson(Map<String, dynamic> json) => Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String,
      description: json['description'] as String?,
      tokenId: json['tokenId'] as String?,
      tokenSerialNumber: json['tokenSerialNumber'] as String?,
      imageUrl: json['imageUrl'] as String?,
      vetRecordUrl: json['vetRecordUrl'] as String?,
      aiPredictionValue: (json['aiPredictionValue'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String,
      isListed: json['isListed'] as bool,
      reviewStatus: $enumDecodeNullable(_$AnimalStatusEnumMap, json['status']),
      reviewComment: json['expertReviewComment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      owner: json['owner'] == null
          ? null
          : AnimalOwner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnimalToJson(Animal instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'gender': instance.gender,
      'description': instance.description,
      'tokenId': instance.tokenId,
      'tokenSerialNumber': instance.tokenSerialNumber,
      'imageUrl': instance.imageUrl,
      'vetRecordUrl': instance.vetRecordUrl,
      'aiPredictionValue': instance.aiPredictionValue,
      'ownerId': instance.ownerId,
      'isListed': instance.isListed,
      'status': _$AnimalStatusEnumMap[instance.reviewStatus],
      'expertReviewComment': instance.reviewComment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'owner': instance.owner,
    };

const _$AnimalStatusEnumMap = {
  AnimalStatus.pendingExpertReview: 'PENDING_EXPERT_REVIEW',
  AnimalStatus.expertApproved: 'EXPERT_APPROVED',
  AnimalStatus.expertRejected: 'EXPERT_REJECTED',
  AnimalStatus.listed: 'LISTED',
  AnimalStatus.minted: 'MINTED',
};

AnimalOwner _$AnimalOwnerFromJson(Map<String, dynamic> json) => AnimalOwner(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AnimalOwnerToJson(AnimalOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };

CreateAnimalRequest _$CreateAnimalRequestFromJson(Map<String, dynamic> json) =>
    CreateAnimalRequest(
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String,
      description: json['description'] as String?,
      aiPredictionValue: (json['aiPredictionValue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateAnimalRequestToJson(
        CreateAnimalRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'gender': instance.gender,
      'description': instance.description,
      'aiPredictionValue': instance.aiPredictionValue,
    };

UpdateAnimalRequest _$UpdateAnimalRequestFromJson(Map<String, dynamic> json) =>
    UpdateAnimalRequest(
      name: json['name'] as String?,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      description: json['description'] as String?,
      aiPredictionValue: (json['aiPredictionValue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateAnimalRequestToJson(
        UpdateAnimalRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'gender': instance.gender,
      'description': instance.description,
      'aiPredictionValue': instance.aiPredictionValue,
    };

ReviewAnimalRequest _$ReviewAnimalRequestFromJson(Map<String, dynamic> json) =>
    ReviewAnimalRequest(
      approved: json['approved'] as bool,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ReviewAnimalRequestToJson(
        ReviewAnimalRequest instance) =>
    <String, dynamic>{
      'approved': instance.approved,
      'comment': instance.comment,
    };
