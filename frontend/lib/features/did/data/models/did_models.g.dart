// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'did_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DidResponse _$DidResponseFromJson(Map<String, dynamic> json) => DidResponse(
      did: json['did'] as String,
      document: json['document'] as Map<String, dynamic>,
      message: json['message'] as String,
    );

Map<String, dynamic> _$DidResponseToJson(DidResponse instance) =>
    <String, dynamic>{
      'did': instance.did,
      'document': instance.document,
      'message': instance.message,
    };

CredentialsResponse _$CredentialsResponseFromJson(Map<String, dynamic> json) =>
    CredentialsResponse(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => Credential.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$CredentialsResponseToJson(
        CredentialsResponse instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
      'count': instance.count,
      'message': instance.message,
    };

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
      context: (json['@context'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      id: json['id'] as String?,
      type: (json['type'] as List<dynamic>?)?.map((e) => e as String).toList(),
      issuer: json['issuer'] as String?,
      issuanceDate: json['issuanceDate'] as String?,
      expirationDate: json['expirationDate'] as String?,
      credentialSubject: json['credentialSubject'] == null
          ? null
          : CredentialSubject.fromJson(
              json['credentialSubject'] as Map<String, dynamic>),
      proof: json['proof'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      '@context': instance.context,
      'id': instance.id,
      'type': instance.type,
      'issuer': instance.issuer,
      'issuanceDate': instance.issuanceDate,
      'expirationDate': instance.expirationDate,
      'credentialSubject': instance.credentialSubject,
      'proof': instance.proof,
    };

CredentialSubject _$CredentialSubjectFromJson(Map<String, dynamic> json) =>
    CredentialSubject(
      id: json['id'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CredentialSubjectToJson(CredentialSubject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
    };

IssueKycCredentialRequest _$IssueKycCredentialRequestFromJson(
        Map<String, dynamic> json) =>
    IssueKycCredentialRequest(
      level: json['level'] as String,
      provider: json['provider'] as String,
      country: json['country'] as String?,
      documentType: json['documentType'] as String?,
    );

Map<String, dynamic> _$IssueKycCredentialRequestToJson(
        IssueKycCredentialRequest instance) =>
    <String, dynamic>{
      'level': instance.level,
      'provider': instance.provider,
      'country': instance.country,
      'documentType': instance.documentType,
    };

IssueReputationCredentialRequest _$IssueReputationCredentialRequestFromJson(
        Map<String, dynamic> json) =>
    IssueReputationCredentialRequest(
      score: (json['score'] as num).toInt(),
      totalTrades: (json['totalTrades'] as num).toInt(),
      successfulTrades: (json['successfulTrades'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
    );

Map<String, dynamic> _$IssueReputationCredentialRequestToJson(
        IssueReputationCredentialRequest instance) =>
    <String, dynamic>{
      'score': instance.score,
      'totalTrades': instance.totalTrades,
      'successfulTrades': instance.successfulTrades,
      'averageRating': instance.averageRating,
    };

IssueVeterinaryCredentialRequest _$IssueVeterinaryCredentialRequestFromJson(
        Map<String, dynamic> json) =>
    IssueVeterinaryCredentialRequest(
      vetId: json['vetId'] as String,
      vetName: json['vetName'] as String,
      examinationDate: json['examinationDate'] as String,
      healthStatus: json['healthStatus'] as String,
      vaccinations: (json['vaccinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      animalId: json['animalId'] as String,
    );

Map<String, dynamic> _$IssueVeterinaryCredentialRequestToJson(
        IssueVeterinaryCredentialRequest instance) =>
    <String, dynamic>{
      'vetId': instance.vetId,
      'vetName': instance.vetName,
      'examinationDate': instance.examinationDate,
      'healthStatus': instance.healthStatus,
      'vaccinations': instance.vaccinations,
      'notes': instance.notes,
      'animalId': instance.animalId,
    };

CredentialResponse _$CredentialResponseFromJson(Map<String, dynamic> json) =>
    CredentialResponse(
      credential:
          Credential.fromJson(json['credential'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$CredentialResponseToJson(CredentialResponse instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'message': instance.message,
    };

VerifyCredentialRequest _$VerifyCredentialRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyCredentialRequest(
      credential: json['credential'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VerifyCredentialRequestToJson(
        VerifyCredentialRequest instance) =>
    <String, dynamic>{
      'credential': instance.credential,
    };

VerifyCredentialResponse _$VerifyCredentialResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyCredentialResponse(
      valid: json['valid'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$VerifyCredentialResponseToJson(
        VerifyCredentialResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'message': instance.message,
    };

RevokeCredentialResponse _$RevokeCredentialResponseFromJson(
        Map<String, dynamic> json) =>
    RevokeCredentialResponse(
      message: json['message'] as String,
      credentialId: json['credentialId'] as String,
    );

Map<String, dynamic> _$RevokeCredentialResponseToJson(
        RevokeCredentialResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'credentialId': instance.credentialId,
    };
