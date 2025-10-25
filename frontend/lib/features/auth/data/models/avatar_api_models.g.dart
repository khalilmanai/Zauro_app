// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvatarData _$AvatarDataFromJson(Map<String, dynamic> json) => AvatarData(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      style: json['style'] as String,
      seed: json['seed'] as String,
    );

Map<String, dynamic> _$AvatarDataToJson(AvatarData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'style': instance.style,
      'seed': instance.seed,
    };

AvatarApiResponse _$AvatarApiResponseFromJson(Map<String, dynamic> json) =>
    AvatarApiResponse(
      avatars: (json['avatars'] as List<dynamic>)
          .map((e) => AvatarData.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      success: json['success'] as bool,
    );

Map<String, dynamic> _$AvatarApiResponseToJson(AvatarApiResponse instance) =>
    <String, dynamic>{
      'avatars': instance.avatars,
      'total': instance.total,
      'success': instance.success,
    };

AvatarStyle _$AvatarStyleFromJson(Map<String, dynamic> json) => AvatarStyle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isAvailable: json['isAvailable'] as bool,
    );

Map<String, dynamic> _$AvatarStyleToJson(AvatarStyle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isAvailable': instance.isAvailable,
    };

AvatarStylesResponse _$AvatarStylesResponseFromJson(
        Map<String, dynamic> json) =>
    AvatarStylesResponse(
      styles: (json['styles'] as List<dynamic>)
          .map((e) => AvatarStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$AvatarStylesResponseToJson(
        AvatarStylesResponse instance) =>
    <String, dynamic>{
      'styles': instance.styles,
      'total': instance.total,
    };
