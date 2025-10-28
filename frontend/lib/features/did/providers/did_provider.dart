import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/did_models.dart';
import '../data/repositories/did_repository.dart';

// DID State
class DidState {
  final DidResponse? did;
  final List<Credential> credentials;
  final bool isLoading;
  final String? error;

  const DidState({
    this.did,
    this.credentials = const [],
    this.isLoading = false,
    this.error,
  });

  DidState copyWith({
    DidResponse? did,
    List<Credential>? credentials,
    bool? isLoading,
    String? error,
  }) {
    return DidState(
      did: did ?? this.did,
      credentials: credentials ?? this.credentials,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper getters
  bool get hasDid => did != null;
  bool get hasCredentials => credentials.isNotEmpty;
  
  List<Credential> get kycCredentials =>
      credentials.where((c) => c.credentialType == 'KYC').toList();
  
  List<Credential> get reputationCredentials =>
      credentials.where((c) => c.credentialType == 'REPUTATION').toList();
  
  List<Credential> get veterinaryCredentials =>
      credentials.where((c) => c.credentialType == 'VETERINARY').toList();
  
  List<Credential> get validCredentials =>
      credentials.where((c) => !c.isExpired).toList();
  
  List<Credential> get expiredCredentials =>
      credentials.where((c) => c.isExpired).toList();
}

// DID Provider
class DidNotifier extends StateNotifier<DidState> {
  final DidRepository _repository;

  DidNotifier(this._repository) : super(const DidState());

  // Get or Create DID
  Future<void> getOrCreateDid() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Try to get existing DID
      try {
        final did = await _repository.getMyDid();
        state = state.copyWith(did: did, isLoading: false);
      } catch (e) {
        // If no DID exists, create one
        final did = await _repository.createDid();
        state = state.copyWith(did: did, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get or create DID: $e',
      );
    }
  }

  // Get My DID
  Future<void> getMyDid() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final did = await _repository.getMyDid();
      state = state.copyWith(did: did, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get DID: $e',
      );
    }
  }

  // Create DID
  Future<void> createDid() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final did = await _repository.createDid();
      state = state.copyWith(did: did, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create DID: $e',
      );
    }
  }

  // Resolve DID
  Future<DidResponse?> resolveDid(String did) async {
    try {
      return await _repository.resolveDid(did);
    } catch (e) {
      state = state.copyWith(error: 'Failed to resolve DID: $e');
      return null;
    }
  }

  // Get My Credentials
  Future<void> getMyCredentials() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getMyCredentials();
      state = state.copyWith(
        credentials: response.credentials,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get credentials: $e',
      );
    }
  }

  // Get Credentials by Type
  Future<void> getCredentialsByType(CredentialType type) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getCredentialsByType(type);
      state = state.copyWith(
        credentials: response.credentials,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get credentials by type: $e',
      );
    }
  }

  // Issue KYC Credential
  Future<bool> issueKycCredential({
    required KycLevel level,
    required String provider,
    String? country,
    String? documentType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.issueKycCredential(
        level: level,
        provider: provider,
        country: country,
        documentType: documentType,
      );
      
      // Add the new credential to the list
      final updatedCredentials = [...state.credentials, response.credential];
      state = state.copyWith(
        credentials: updatedCredentials,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to issue KYC credential: $e',
      );
      return false;
    }
  }

  // Issue Reputation Credential
  Future<bool> issueReputationCredential({
    required int score,
    required int totalTrades,
    required int successfulTrades,
    required double averageRating,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.issueReputationCredential(
        score: score,
        totalTrades: totalTrades,
        successfulTrades: successfulTrades,
        averageRating: averageRating,
      );
      
      // Add the new credential to the list
      final updatedCredentials = [...state.credentials, response.credential];
      state = state.copyWith(
        credentials: updatedCredentials,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to issue reputation credential: $e',
      );
      return false;
    }
  }

  // Issue Veterinary Credential
  Future<bool> issueVeterinaryCredential({
    required String vetId,
    required String vetName,
    required String examinationDate,
    required HealthStatus healthStatus,
    required List<String> vaccinations,
    String? notes,
    required String animalId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.issueVeterinaryCredential(
        vetId: vetId,
        vetName: vetName,
        examinationDate: examinationDate,
        healthStatus: healthStatus,
        vaccinations: vaccinations,
        notes: notes,
        animalId: animalId,
      );
      
      // Add the new credential to the list
      final updatedCredentials = [...state.credentials, response.credential];
      state = state.copyWith(
        credentials: updatedCredentials,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to issue veterinary credential: $e',
      );
      return false;
    }
  }

  // Verify Credential
  Future<bool> verifyCredential(Map<String, dynamic> credential) async {
    try {
      final response = await _repository.verifyCredential(credential);
      return response.valid;
    } catch (e) {
      state = state.copyWith(error: 'Failed to verify credential: $e');
      return false;
    }
  }

  // Revoke Credential
  Future<bool> revokeCredential(String credentialId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.revokeCredential(credentialId);
      
      // Remove the credential from the list
      final updatedCredentials = state.credentials
          .where((c) => c.id != credentialId)
          .toList();
      
      state = state.copyWith(
        credentials: updatedCredentials,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to revoke credential: $e',
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void reset() {
    state = const DidState();
  }
}

// Provider
final didProvider = StateNotifierProvider<DidNotifier, DidState>((ref) {
  final repository = ref.watch(didRepositoryProvider);
  return DidNotifier(repository);
});

// Helper providers for specific data

// Check if user has valid KYC
final hasValidKycProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(didRepositoryProvider);
  return await repository.hasValidKyc();
});

// Get highest KYC level
final highestKycLevelProvider = FutureProvider<KycLevel?>((ref) async {
  final repository = ref.watch(didRepositoryProvider);
  return await repository.getHighestKycLevel();
});

// Get reputation score
final reputationScoreProvider = FutureProvider<int?>((ref) async {
  final repository = ref.watch(didRepositoryProvider);
  return await repository.getReputationScore();
});

// Get veterinary credentials for animal
final animalVeterinaryCredentialsProvider = FutureProvider.family<
    List<Credential>, String>((ref, animalId) async {
  final repository = ref.watch(didRepositoryProvider);
  return await repository.getVeterinaryCredentialsForAnimal(animalId);
});


