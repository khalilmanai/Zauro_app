import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/did_models.dart';

// DID Repository Provider
final didRepositoryProvider = Provider<DidRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DidRepository(apiClient);
});

class DidRepository {
  final ApiClient _apiClient;

  DidRepository(this._apiClient);

  // Get My DID
  Future<DidResponse> getMyDid() async {
    try {
      final response = await _apiClient.getMyDid();
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to get DID: ${response.message}');
    } catch (e) {
      throw Exception('Failed to get DID: $e');
    }
  }

  // Create DID
  Future<DidResponse> createDid() async {
    try {
      final response = await _apiClient.createDid();
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to create DID: ${response.message}');
    } catch (e) {
      throw Exception('Failed to create DID: $e');
    }
  }

  // Resolve DID
  Future<DidResponse> resolveDid(String did) async {
    try {
      final response = await _apiClient.resolveDid(did);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to resolve DID: ${response.message}');
    } catch (e) {
      throw Exception('Failed to resolve DID: $e');
    }
  }

  // Get My Credentials
  Future<CredentialsResponse> getMyCredentials() async {
    try {
      final response = await _apiClient.getMyCredentials();
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to get credentials: ${response.message}');
    } catch (e) {
      throw Exception('Failed to get credentials: $e');
    }
  }

  // Get Credentials by Type
  Future<CredentialsResponse> getCredentialsByType(
      CredentialType type) async {
    try {
      final response = await _apiClient.getCredentialsByType(type.value);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to get credentials by type: ${response.message}');
    } catch (e) {
      throw Exception('Failed to get credentials by type: $e');
    }
  }

  // Issue KYC Credential
  Future<CredentialResponse> issueKycCredential({
    required KycLevel level,
    required String provider,
    String? country,
    String? documentType,
  }) async {
    try {
      final request = IssueKycCredentialRequest(
        level: level.value,
        provider: provider,
        country: country,
        documentType: documentType,
      );
      final response = await _apiClient.issueKycCredential(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to issue KYC credential: ${response.message}');
    } catch (e) {
      throw Exception('Failed to issue KYC credential: $e');
    }
  }

  // Issue Reputation Credential
  Future<CredentialResponse> issueReputationCredential({
    required int score,
    required int totalTrades,
    required int successfulTrades,
    required double averageRating,
  }) async {
    try {
      final request = IssueReputationCredentialRequest(
        score: score,
        totalTrades: totalTrades,
        successfulTrades: successfulTrades,
        averageRating: averageRating,
      );
      final response = await _apiClient.issueReputationCredential(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception(
          'Failed to issue reputation credential: ${response.message}');
    } catch (e) {
      throw Exception('Failed to issue reputation credential: $e');
    }
  }

  // Issue Veterinary Credential
  Future<CredentialResponse> issueVeterinaryCredential({
    required String vetId,
    required String vetName,
    required String examinationDate,
    required HealthStatus healthStatus,
    required List<String> vaccinations,
    String? notes,
    required String animalId,
  }) async {
    try {
      final request = IssueVeterinaryCredentialRequest(
        vetId: vetId,
        vetName: vetName,
        examinationDate: examinationDate,
        healthStatus: healthStatus.value,
        vaccinations: vaccinations,
        notes: notes,
        animalId: animalId,
      );
      final response = await _apiClient.issueVeterinaryCredential(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception(
          'Failed to issue veterinary credential: ${response.message}');
    } catch (e) {
      throw Exception('Failed to issue veterinary credential: $e');
    }
  }

  // Verify Credential
  Future<VerifyCredentialResponse> verifyCredential(
      Map<String, dynamic> credential) async {
    try {
      final request = VerifyCredentialRequest(credential: credential);
      final response = await _apiClient.verifyCredential(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to verify credential: ${response.message}');
    } catch (e) {
      throw Exception('Failed to verify credential: $e');
    }
  }

  // Revoke Credential
  Future<RevokeCredentialResponse> revokeCredential(
      String credentialId) async {
    try {
      final response = await _apiClient.revokeCredential(credentialId);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to revoke credential: ${response.message}');
    } catch (e) {
      throw Exception('Failed to revoke credential: $e');
    }
  }

  // Helper Methods

  // Get KYC Credentials
  Future<List<Credential>> getKycCredentials() async {
    try {
      final response = await getCredentialsByType(CredentialType.kyc);
      return response.credentials;
    } catch (e) {
      throw Exception('Failed to get KYC credentials: $e');
    }
  }

  // Get Reputation Credentials
  Future<List<Credential>> getReputationCredentials() async {
    try {
      final response = await getCredentialsByType(CredentialType.reputation);
      return response.credentials;
    } catch (e) {
      throw Exception('Failed to get reputation credentials: $e');
    }
  }

  // Get Veterinary Credentials
  Future<List<Credential>> getVeterinaryCredentials() async {
    try {
      final response = await getCredentialsByType(CredentialType.veterinary);
      return response.credentials;
    } catch (e) {
      throw Exception('Failed to get veterinary credentials: $e');
    }
  }

  // Check if user has valid KYC
  Future<bool> hasValidKyc() async {
    try {
      final credentials = await getKycCredentials();
      return credentials.any((c) => !c.isExpired);
    } catch (e) {
      return false;
    }
  }

  // Get user's highest KYC level
  Future<KycLevel?> getHighestKycLevel() async {
    try {
      final credentials = await getKycCredentials();
      if (credentials.isEmpty) return null;

      // Filter valid credentials
      final validCredentials =
          credentials.where((c) => !c.isExpired).toList();
      if (validCredentials.isEmpty) return null;

      // Extract level from credential subject data
      for (final credential in validCredentials) {
        final level = credential.credentialSubject?.data?['level'] as String?;
        if (level == 'premium') return KycLevel.premium;
      }
      for (final credential in validCredentials) {
        final level = credential.credentialSubject?.data?['level'] as String?;
        if (level == 'enhanced') return KycLevel.enhanced;
      }
      return KycLevel.basic;
    } catch (e) {
      return null;
    }
  }

  // Get user's reputation score
  Future<int?> getReputationScore() async {
    try {
      final credentials = await getReputationCredentials();
      if (credentials.isEmpty) return null;

      // Get the latest valid credential
      final validCredentials =
          credentials.where((c) => !c.isExpired).toList();
      if (validCredentials.isEmpty) return null;

      // Sort by issuance date (most recent first)
      validCredentials.sort((a, b) {
        final aDate = DateTime.tryParse(a.issuanceDate ?? '');
        final bDate = DateTime.tryParse(b.issuanceDate ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      final latestCredential = validCredentials.first;
      return latestCredential.credentialSubject?.data?['score'] as int?;
    } catch (e) {
      return null;
    }
  }

  // Get veterinary credentials for a specific animal
  Future<List<Credential>> getVeterinaryCredentialsForAnimal(
      String animalId) async {
    try {
      final credentials = await getVeterinaryCredentials();
      return credentials
          .where((c) =>
              c.credentialSubject?.data?['animalId'] == animalId &&
              !c.isExpired)
          .toList();
    } catch (e) {
      return [];
    }
  }
}


