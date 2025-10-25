import 'package:json_annotation/json_annotation.dart';

import 'auth_models.dart';

part 'avatar_api_models.g.dart';

@JsonSerializable()
class AvatarData {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String style;
  final String seed;

  const AvatarData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.style,
    required this.seed,
  });

  factory AvatarData.fromJson(Map<String, dynamic> json) =>
      _$AvatarDataFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarDataToJson(this);

  // Convert to the existing Avatar model for compatibility
  Avatar toAvatar() {
    return Avatar(
      id: id,
      name: name,
      imageUrl: imageUrl,
      category: category,
    );
  }
}

@JsonSerializable()
class AvatarApiResponse {
  final List<AvatarData> avatars;
  final int total;
  final bool success;

  const AvatarApiResponse({
    required this.avatars,
    required this.total,
    required this.success,
  });

  factory AvatarApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AvatarApiResponseFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'avatars': avatars.map((e) => e.toJson()).toList(),
        'total': total,
        'success': success,
      };
}

@JsonSerializable()
class AvatarStyle {
  final String id;
  final String name;
  final String description;
  final bool isAvailable;

  const AvatarStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.isAvailable,
  });

  factory AvatarStyle.fromJson(Map<String, dynamic> json) =>
      _$AvatarStyleFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarStyleToJson(this);
}

@JsonSerializable()
class AvatarStylesResponse {
  final List<AvatarStyle> styles;
  final int total;

  const AvatarStylesResponse({
    required this.styles,
    required this.total,
  });

  factory AvatarStylesResponse.fromJson(Map<String, dynamic> json) =>
      _$AvatarStylesResponseFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'styles': styles.map((e) => e.toJson()).toList(),
        'total': total,
      };
}
