import 'package:json_annotation/json_annotation.dart';

part 'animal_models.g.dart';

// Animal Model
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
    );
  }

  String get displaySpecies {
    switch (species) {
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
