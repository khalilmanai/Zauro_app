import 'package:json_annotation/json_annotation.dart';

part 'collection_models.g.dart';

// Collection Model
@JsonSerializable()
class Collection {
  final String id;
  final String tokenId;
  final String name;
  final String symbol;
  final String? memo;
  final int? maxSupply;
  final int currentSupply;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Collection({
    required this.id,
    required this.tokenId,
    required this.name,
    required this.symbol,
    this.memo,
    this.maxSupply,
    required this.currentSupply,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  Collection copyWith({
    String? id,
    String? tokenId,
    String? name,
    String? symbol,
    String? memo,
    int? maxSupply,
    int? currentSupply,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      memo: memo ?? this.memo,
      maxSupply: maxSupply ?? this.maxSupply,
      currentSupply: currentSupply ?? this.currentSupply,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFull => maxSupply != null && currentSupply >= maxSupply!;
  
  double get fillPercentage {
    if (maxSupply == null || maxSupply == 0) return 0;
    return (currentSupply / maxSupply!) * 100;
  }

  int get remainingCapacity {
    if (maxSupply == null) return -1; // Unlimited
    return maxSupply! - currentSupply;
  }
}

// Create Collection Request
@JsonSerializable()
class CreateCollectionRequest {
  final String name;
  final String symbol;
  final String? memo;
  final int? maxSupply;
  final bool? isDefault;

  const CreateCollectionRequest({
    required this.name,
    required this.symbol,
    this.memo,
    this.maxSupply,
    this.isDefault,
  });

  factory CreateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCollectionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCollectionRequestToJson(this);
}

// Rotate Collection Request
@JsonSerializable()
class RotateCollectionRequest {
  final String? namePrefix;
  final String? symbolPrefix;
  final String? memo;

  const RotateCollectionRequest({
    this.namePrefix,
    this.symbolPrefix,
    this.memo,
  });

  factory RotateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$RotateCollectionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RotateCollectionRequestToJson(this);
}

// Collections Response (for list endpoint)
@JsonSerializable()
class CollectionsResponse {
  final List<Collection> collections;
  final int total;

  const CollectionsResponse({
    required this.collections,
    required this.total,
  });

  factory CollectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionsResponseToJson(this);
}

// Collection Stats (for dashboard/analytics)
class CollectionStats {
  final int totalCollections;
  final int activeCollections;
  final int fullCollections;
  final int totalNFTs;
  final Collection? defaultCollection;

  const CollectionStats({
    required this.totalCollections,
    required this.activeCollections,
    required this.fullCollections,
    required this.totalNFTs,
    this.defaultCollection,
  });

  CollectionStats copyWith({
    int? totalCollections,
    int? activeCollections,
    int? fullCollections,
    int? totalNFTs,
    Collection? defaultCollection,
  }) {
    return CollectionStats(
      totalCollections: totalCollections ?? this.totalCollections,
      activeCollections: activeCollections ?? this.activeCollections,
      fullCollections: fullCollections ?? this.fullCollections,
      totalNFTs: totalNFTs ?? this.totalNFTs,
      defaultCollection: defaultCollection ?? this.defaultCollection,
    );
  }

  factory CollectionStats.fromCollections(List<Collection> collections) {
    final defaultCollection = collections.where((c) => c.isDefault).firstOrNull;
    return CollectionStats(
      totalCollections: collections.length,
      activeCollections: collections.where((c) => c.isActive).length,
      fullCollections: collections.where((c) => c.isFull).length,
      totalNFTs: collections.fold(0, (sum, c) => sum + c.currentSupply),
      defaultCollection: defaultCollection,
    );
  }
}

// Collection Filter
class CollectionFilter {
  final bool? isDefault;
  final bool? isActive;
  final bool? isFull;
  final String? searchQuery;

  const CollectionFilter({
    this.isDefault,
    this.isActive,
    this.isFull,
    this.searchQuery,
  });

  CollectionFilter copyWith({
    bool? isDefault,
    bool? isActive,
    bool? isFull,
    String? searchQuery,
  }) {
    return CollectionFilter(
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      isFull: isFull ?? this.isFull,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Collection> apply(List<Collection> collections) {
    var filtered = collections;

    if (isDefault != null) {
      filtered = filtered.where((c) => c.isDefault == isDefault).toList();
    }

    if (isActive != null) {
      filtered = filtered.where((c) => c.isActive == isActive).toList();
    }

    if (isFull != null) {
      filtered = filtered.where((c) => c.isFull == isFull).toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.symbol.toLowerCase().contains(query) ||
              c.tokenId.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }
}

// Collection Sort Options
enum CollectionSortBy {
  nameAsc,
  nameDesc,
  createdAtAsc,
  createdAtDesc,
  currentSupplyAsc,
  currentSupplyDesc,
  fillPercentageAsc,
  fillPercentageDesc,
}

extension CollectionSortByExtension on CollectionSortBy {
  String get displayName {
    switch (this) {
      case CollectionSortBy.nameAsc:
        return 'Name (A-Z)';
      case CollectionSortBy.nameDesc:
        return 'Name (Z-A)';
      case CollectionSortBy.createdAtAsc:
        return 'Oldest First';
      case CollectionSortBy.createdAtDesc:
        return 'Newest First';
      case CollectionSortBy.currentSupplyAsc:
        return 'Supply (Low to High)';
      case CollectionSortBy.currentSupplyDesc:
        return 'Supply (High to Low)';
      case CollectionSortBy.fillPercentageAsc:
        return 'Fill % (Low to High)';
      case CollectionSortBy.fillPercentageDesc:
        return 'Fill % (High to Low)';
    }
  }

  List<Collection> apply(List<Collection> collections) {
    final sorted = List<Collection>.from(collections);
    switch (this) {
      case CollectionSortBy.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CollectionSortBy.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CollectionSortBy.createdAtAsc:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CollectionSortBy.createdAtDesc:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CollectionSortBy.currentSupplyAsc:
        sorted.sort((a, b) => a.currentSupply.compareTo(b.currentSupply));
        break;
      case CollectionSortBy.currentSupplyDesc:
        sorted.sort((a, b) => b.currentSupply.compareTo(a.currentSupply));
        break;
      case CollectionSortBy.fillPercentageAsc:
        sorted.sort((a, b) => a.fillPercentage.compareTo(b.fillPercentage));
        break;
      case CollectionSortBy.fillPercentageDesc:
        sorted.sort((a, b) => b.fillPercentage.compareTo(a.fillPercentage));
        break;
    }
    return sorted;
  }
}


