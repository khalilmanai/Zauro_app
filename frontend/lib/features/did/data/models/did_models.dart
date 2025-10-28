import 'package:json_annotation/json_annotation.dart';

part 'did_models.g.dart';

// DID Response
@JsonSerializable()
class DidResponse {
  final String did;
  final Map<String, dynamic> document;
  final String message;

  const DidResponse({
    required this.did,
    required this.document,
    required this.message,
  });

  factory DidResponse.fromJson(Map<String, dynamic> json) =>
      _$DidResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DidResponseToJson(this);
}

// Credentials Response
@JsonSerializable()
class CredentialsResponse {
  final List<Credential> credentials;
  final int count;
  final String message;

  const CredentialsResponse({
    required this.credentials,
    required this.count,
    required this.message,
  });

  factory CredentialsResponse.fromJson(Map<String, dynamic> json) =>
      _$CredentialsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialsResponseToJson(this);
}

// Credential Model
@JsonSerializable()
class Credential {
  @JsonKey(name: '@context')
  final List<String>? context;
  final String? id;
  final List<String>? type;
  final String? issuer;
  final String? issuanceDate;
  final String? expirationDate;
  final CredentialSubject? credentialSubject;
  final Map<String, dynamic>? proof;

  const Credential({
    this.context,
    this.id,
    this.type,
    this.issuer,
    this.issuanceDate,
    this.expirationDate,
    this.credentialSubject,
    this.proof,
  });

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialToJson(this);

  String get credentialType {
    if (type == null || type!.isEmpty) return 'Unknown';
    // Return the last type (which is usually the specific credential type)
    return type!.last.replaceAll('Credential', '');
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    try {
      final expDate = DateTime.parse(expirationDate!);
      return DateTime.now().isAfter(expDate);
    } catch (e) {
      return false;
    }
  }
}

// Credential Subject
@JsonSerializable()
class CredentialSubject {
  final String? id;
  final Map<String, dynamic>? data;

  const CredentialSubject({this.id, this.data});

  factory CredentialSubject.fromJson(Map<String, dynamic> json) {
    // Extract 'id' and treat everything else as 'data'
    final id = json['id'] as String?;
    final data = Map<String, dynamic>.from(json)..remove('id');
    return CredentialSubject(id: id, data: data.isEmpty ? null : data);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (id != null) json['id'] = id;
    if (data != null) json.addAll(data!);
    return json;
  }
}

// Issue KYC Credential Request
@JsonSerializable()
class IssueKycCredentialRequest {
  final String level; // basic | enhanced | premium
  final String provider;
  final String? country;
  final String? documentType;

  const IssueKycCredentialRequest({
    required this.level,
    required this.provider,
    this.country,
    this.documentType,
  });

  factory IssueKycCredentialRequest.fromJson(Map<String, dynamic> json) =>
      _$IssueKycCredentialRequestFromJson(json);
  Map<String, dynamic> toJson() => _$IssueKycCredentialRequestToJson(this);
}

// Issue Reputation Credential Request
@JsonSerializable()
class IssueReputationCredentialRequest {
  final int score;
  final int totalTrades;
  final int successfulTrades;
  final double averageRating;

  const IssueReputationCredentialRequest({
    required this.score,
    required this.totalTrades,
    required this.successfulTrades,
    required this.averageRating,
  });

  factory IssueReputationCredentialRequest.fromJson(
          Map<String, dynamic> json) =>
      _$IssueReputationCredentialRequestFromJson(json);
  Map<String, dynamic> toJson() =>
      _$IssueReputationCredentialRequestToJson(this);
}

// Issue Veterinary Credential Request
@JsonSerializable()
class IssueVeterinaryCredentialRequest {
  final String vetId;
  final String vetName;
  final String examinationDate;
  final String healthStatus; // healthy | sick | recovering
  final List<String> vaccinations;
  final String? notes;
  final String animalId;

  const IssueVeterinaryCredentialRequest({
    required this.vetId,
    required this.vetName,
    required this.examinationDate,
    required this.healthStatus,
    required this.vaccinations,
    this.notes,
    required this.animalId,
  });

  factory IssueVeterinaryCredentialRequest.fromJson(
          Map<String, dynamic> json) =>
      _$IssueVeterinaryCredentialRequestFromJson(json);
  Map<String, dynamic> toJson() =>
      _$IssueVeterinaryCredentialRequestToJson(this);
}

// Credential Response (for issue operations)
@JsonSerializable()
class CredentialResponse {
  final Credential credential;
  final String message;

  const CredentialResponse({
    required this.credential,
    required this.message,
  });

  factory CredentialResponse.fromJson(Map<String, dynamic> json) =>
      _$CredentialResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialResponseToJson(this);
}

// Verify Credential Request
@JsonSerializable()
class VerifyCredentialRequest {
  final Map<String, dynamic> credential;

  const VerifyCredentialRequest({required this.credential});

  factory VerifyCredentialRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyCredentialRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyCredentialRequestToJson(this);
}

// Verify Credential Response
@JsonSerializable()
class VerifyCredentialResponse {
  final bool valid;
  final String message;

  const VerifyCredentialResponse({
    required this.valid,
    required this.message,
  });

  factory VerifyCredentialResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyCredentialResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyCredentialResponseToJson(this);
}

// Revoke Credential Response
@JsonSerializable()
class RevokeCredentialResponse {
  final String message;
  final String credentialId;

  const RevokeCredentialResponse({
    required this.message,
    required this.credentialId,
  });

  factory RevokeCredentialResponse.fromJson(Map<String, dynamic> json) =>
      _$RevokeCredentialResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RevokeCredentialResponseToJson(this);
}

// Credential Types
enum CredentialType {
  kyc,
  reputation,
  veterinary,
}

extension CredentialTypeExtension on CredentialType {
  String get value {
    switch (this) {
      case CredentialType.kyc:
        return 'KYC';
      case CredentialType.reputation:
        return 'REPUTATION';
      case CredentialType.veterinary:
        return 'VETERINARY';
    }
  }

  String get displayName {
    switch (this) {
      case CredentialType.kyc:
        return 'KYC Verification';
      case CredentialType.reputation:
        return 'Reputation Score';
      case CredentialType.veterinary:
        return 'Veterinary Record';
    }
  }
}

// KYC Levels
enum KycLevel {
  basic,
  enhanced,
  premium,
}

extension KycLevelExtension on KycLevel {
  String get value {
    switch (this) {
      case KycLevel.basic:
        return 'basic';
      case KycLevel.enhanced:
        return 'enhanced';
      case KycLevel.premium:
        return 'premium';
    }
  }

  String get displayName {
    switch (this) {
      case KycLevel.basic:
        return 'Basic';
      case KycLevel.enhanced:
        return 'Enhanced';
      case KycLevel.premium:
        return 'Premium';
    }
  }
}

// Health Status
enum HealthStatus {
  healthy,
  sick,
  recovering,
}

extension HealthStatusExtension on HealthStatus {
  String get value {
    switch (this) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.sick:
        return 'sick';
      case HealthStatus.recovering:
        return 'recovering';
    }
  }

  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Healthy';
      case HealthStatus.sick:
        return 'Sick';
      case HealthStatus.recovering:
        return 'Recovering';
    }
  }
}


