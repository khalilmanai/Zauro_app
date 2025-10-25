import 'package:json_annotation/json_annotation.dart';

part 'trade_models.g.dart';

// Trade Model
@JsonSerializable()
class Trade {
  final String id;
  final String animalId;
  final String sellerId;
  final String? buyerId;
  final double price;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final TradeAnimal? animal;
  final TradeUser? seller;
  final TradeUser? buyer;

  const Trade({
    required this.id,
    required this.animalId,
    required this.sellerId,
    this.buyerId,
    required this.price,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.animal,
    this.seller,
    this.buyer,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
  Map<String, dynamic> toJson() => _$TradeToJson(this);

  Trade copyWith({
    String? id,
    String? animalId,
    String? sellerId,
    String? buyerId,
    double? price,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    TradeAnimal? animal,
    TradeUser? seller,
    TradeUser? buyer,
  }) {
    return Trade(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      animal: animal ?? this.animal,
      seller: seller ?? this.seller,
      buyer: buyer ?? this.buyer,
    );
  }

  String get displayStatus {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'LISTED':
        return 'Listed';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  bool get isActive => status == 'LISTED' || status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get canBuy => status == 'LISTED' && buyerId == null;
}

// Trade Animal Model
@JsonSerializable()
class TradeAnimal {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String gender;
  final String? imageUrl;
  final String? tokenId;

  const TradeAnimal({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    required this.gender,
    this.imageUrl,
    this.tokenId,
  });

  factory TradeAnimal.fromJson(Map<String, dynamic> json) =>
      _$TradeAnimalFromJson(json);
  Map<String, dynamic> toJson() => _$TradeAnimalToJson(this);

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
}

// Trade User Model
@JsonSerializable()
class TradeUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const TradeUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory TradeUser.fromJson(Map<String, dynamic> json) =>
      _$TradeUserFromJson(json);
  Map<String, dynamic> toJson() => _$TradeUserToJson(this);

  String get fullName => '$firstName $lastName';
}

// Create Trade Request
@JsonSerializable()
class CreateTradeRequest {
  final String animalId;
  final double price;
  final String currency;

  const CreateTradeRequest({
    required this.animalId,
    required this.price,
    required this.currency,
  });

  factory CreateTradeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTradeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTradeRequestToJson(this);
}

// Trade Filter
class TradeFilter {
  final String? status;
  final String? sellerId;
  final String? buyerId;
  final String? currency;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;

  const TradeFilter({
    this.status,
    this.sellerId,
    this.buyerId,
    this.currency,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });

  TradeFilter copyWith({
    String? status,
    String? sellerId,
    String? buyerId,
    String? currency,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) {
    return TradeFilter(
      status: status ?? this.status,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      currency: currency ?? this.currency,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (status != null) params['status'] = status;

    return params;
  }
}

// Trade Sort Options
enum TradeSortBy {
  priceAsc,
  priceDesc,
  createdAtAsc,
  createdAtDesc,
  animalNameAsc,
  animalNameDesc,
}

extension TradeSortByExtension on TradeSortBy {
  String get displayName {
    switch (this) {
      case TradeSortBy.priceAsc:
        return 'Price (Low to High)';
      case TradeSortBy.priceDesc:
        return 'Price (High to Low)';
      case TradeSortBy.createdAtAsc:
        return 'Oldest First';
      case TradeSortBy.createdAtDesc:
        return 'Newest First';
      case TradeSortBy.animalNameAsc:
        return 'Animal Name (A-Z)';
      case TradeSortBy.animalNameDesc:
        return 'Animal Name (Z-A)';
    }
  }
}
