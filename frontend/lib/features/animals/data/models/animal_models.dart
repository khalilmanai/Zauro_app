import 'package:json_annotation/json_annotation.dart';

part 'animal_models.g.dart';

// Animal Status Enum (matching backend)
enum AnimalStatus {
  @JsonValue('PENDING_EXPERT_REVIEW')
  pendingExpertReview,
  @JsonValue('EXPERT_APPROVED')
  expertApproved,
  @JsonValue('EXPERT_REJECTED')
  expertRejected,
  @JsonValue('LISTED')
  listed,
  @JsonValue('MINTED')
  minted,
}

extension AnimalStatusExtension on AnimalStatus {
  String get displayName {
    switch (this) {
      case AnimalStatus.pendingExpertReview:
        return 'Pending Review';
      case AnimalStatus.expertApproved:
        return 'Approved';
      case AnimalStatus.expertRejected:
        return 'Rejected';
      case AnimalStatus.listed:
        return 'Listed';
      case AnimalStatus.minted:
        return 'Minted';
    }
  }

  bool get isPending => this == AnimalStatus.pendingExpertReview;
  bool get isApproved => this == AnimalStatus.expertApproved;
  bool get isRejected => this == AnimalStatus.expertRejected;
  bool get isMinted => this == AnimalStatus.minted;
}

// Animal Model (updated to match backend response)
@JsonSerializable()
class Animal {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String gender;
  final String? description;
  final String? tokenId;
  final String? tokenSerialNumber;
  final String? imageUrl;
  final String? vetRecordUrl;
  final double? aiPredictionValue;
  final String ownerId;
  final bool isListed;
  final AnimalStatus? reviewStatus; // New field matching backend
  final String? reviewComment; // New field for admin review comments
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnimalOwner? owner;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    required this.gender,
    this.description,
    this.tokenId,
    this.tokenSerialNumber,
    this.imageUrl,
    this.vetRecordUrl,
    this.aiPredictionValue,
    required this.ownerId,
    required this.isListed,
    this.reviewStatus,
    this.reviewComment,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalToJson(this);

  Animal copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    String? description,
    String? tokenId,
    String? tokenSerialNumber,
    String? imageUrl,
    String? vetRecordUrl,
    double? aiPredictionValue,
    String? ownerId,
    bool? isListed,
    AnimalStatus? reviewStatus,
    String? reviewComment,
    DateTime? createdAt,
    DateTime? updatedAt,
    AnimalOwner? owner,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      tokenId: tokenId ?? this.tokenId,
      tokenSerialNumber: tokenSerialNumber ?? this.tokenSerialNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      vetRecordUrl: vetRecordUrl ?? this.vetRecordUrl,
      aiPredictionValue: aiPredictionValue ?? this.aiPredictionValue,
      ownerId: ownerId ?? this.ownerId,
      isListed: isListed ?? this.isListed,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewComment: reviewComment ?? this.reviewComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
    );
  }

  String get displaySpecies {
    switch (species) {
      case 'DOG':
        return 'Dog';
      case 'CAT':
        return 'Cat';
      case 'BIRD':
        return 'Bird';
      case 'FISH':
        return 'Fish';
      case 'REPTILE':
        return 'Reptile';
      case 'EXOTIC':
        return 'Exotic';
      case 'COW':
        return 'Cow';
      case 'GOAT':
        return 'Goat';
      case 'SHEEP':
        return 'Sheep';
      case 'OTHER':
        return 'Other';
      default:
        return species;
    }
  }

  String get displayGender {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      default:
        return gender;
    }
  }

  String get ageDisplay {
    if (age == null) return 'Age unknown';
    if (age == 1) return '1 year old';
    return '$age years old';
  }

  bool get hasNFT => tokenId != null && tokenSerialNumber != null;
  bool get needsReview => reviewStatus == AnimalStatus.pendingExpertReview;
  bool get isApproved => reviewStatus == AnimalStatus.expertApproved;
  bool get canMint => isApproved && !hasNFT;
}

// Animal Owner Model
@JsonSerializable()
class AnimalOwner {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const AnimalOwner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AnimalOwner.fromJson(Map<String, dynamic> json) =>
      _$AnimalOwnerFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalOwnerToJson(this);

  String get fullName => '$firstName $lastName';
}

// Create Animal Request
@JsonSerializable()
class CreateAnimalRequest {
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String gender;
  final String? description;
  final double? aiPredictionValue;

  const CreateAnimalRequest({
    required this.name,
    required this.species,
    this.breed,
    this.age,
    required this.gender,
    this.description,
    this.aiPredictionValue,
  });

  factory CreateAnimalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnimalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAnimalRequestToJson(this);
}

// Update Animal Request
@JsonSerializable()
class UpdateAnimalRequest {
  final String? name;
  final String? species;
  final String? breed;
  final int? age;
  final String? gender;
  final String? description;
  final double? aiPredictionValue;

  const UpdateAnimalRequest({
    this.name,
    this.species,
    this.breed,
    this.age,
    this.gender,
    this.description,
    this.aiPredictionValue,
  });

  factory UpdateAnimalRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAnimalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAnimalRequestToJson(this);
}

// Animal Filter
class AnimalFilter {
  final String? species;
  final String? ownerId;
  final bool? isListed;
  final String? searchQuery;
  final int? minAge;
  final int? maxAge;
  final double? minPrice;
  final double? maxPrice;

  const AnimalFilter({
    this.species,
    this.ownerId,
    this.isListed,
    this.searchQuery,
    this.minAge,
    this.maxAge,
    this.minPrice,
    this.maxPrice,
  });

  AnimalFilter copyWith({
    String? species,
    String? ownerId,
    bool? isListed,
    String? searchQuery,
    int? minAge,
    int? maxAge,
    double? minPrice,
    double? maxPrice,
  }) {
    return AnimalFilter(
      species: species ?? this.species,
      ownerId: ownerId ?? this.ownerId,
      isListed: isListed ?? this.isListed,
      searchQuery: searchQuery ?? this.searchQuery,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (ownerId != null) params['ownerId'] = ownerId;

    return params;
  }
}

// Review Animal Request - Matching backend DTO
@JsonSerializable()
class ReviewAnimalRequest {
  final bool approved;
  final String? comment;

  const ReviewAnimalRequest({
    required this.approved,
    this.comment,
  });

  factory ReviewAnimalRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewAnimalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewAnimalRequestToJson(this);
}

// Animal Sort Options
enum AnimalSortBy {
  nameAsc,
  nameDesc,
  ageAsc,
  ageDesc,
  priceAsc,
  priceDesc,
  createdAtAsc,
  createdAtDesc,
}

extension AnimalSortByExtension on AnimalSortBy {
  String get displayName {
    switch (this) {
      case AnimalSortBy.nameAsc:
        return 'Name (A-Z)';
      case AnimalSortBy.nameDesc:
        return 'Name (Z-A)';
      case AnimalSortBy.ageAsc:
        return 'Age (Youngest)';
      case AnimalSortBy.ageDesc:
        return 'Age (Oldest)';
      case AnimalSortBy.priceAsc:
        return 'Price (Low to High)';
      case AnimalSortBy.priceDesc:
        return 'Price (High to Low)';
      case AnimalSortBy.createdAtAsc:
        return 'Oldest First';
      case AnimalSortBy.createdAtDesc:
        return 'Newest First';
    }
  }
}
