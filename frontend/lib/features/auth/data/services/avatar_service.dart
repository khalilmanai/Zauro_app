import 'package:dio/dio.dart';
import '../models/avatar_api_models.dart';

class AvatarService {
  static const String _baseUrl = 'https://avatar.iran.liara.run/public';
  static const int _minId = 0;
  static const int _maxId = 100;

  final Dio _dio = Dio();

  /// Fetches a batch of random avatars from Iran Liara API
  Future<List<AvatarData>> fetchRandomAvatars({int count = 5}) async {
    try {
      List<AvatarData> avatars = [];

      // Generate avatars using random IDs for variety
      for (int i = 0; i < count; i++) {
        final id = _generateRandomId();
        final avatarData = await _generateAvatar(id.toString());
        if (avatarData != null) {
          avatars.add(avatarData);
        }
      }

      return avatars;
    } catch (e) {
      throw Exception('Failed to fetch avatars: $e');
    }
  }

  /// Fetches additional avatars for lazy loading
  Future<List<AvatarData>> fetchMoreAvatars(
      {int count = 5, int offset = 0}) async {
    try {
      List<AvatarData> avatars = [];

      // Generate more avatars with offset for variety
      for (int i = offset; i < offset + count; i++) {
        final id = _generateRandomIdWithOffset(i);
        final avatarData = await _generateAvatar(id.toString());
        if (avatarData != null) {
          avatars.add(avatarData);
        }
      }

      return avatars;
    } catch (e) {
      throw Exception('Failed to fetch more avatars: $e');
    }
  }

  /// Generates a random ID with offset for consistent pagination
  int _generateRandomIdWithOffset(int offset) {
    return (offset * 7 + DateTime.now().millisecondsSinceEpoch) %
            (_maxId - _minId + 1) +
        _minId;
  }

  /// Generates a single avatar using Iran Liara API
  Future<AvatarData?> _generateAvatar(String avatarId) async {
    try {
      // Iran Liara API URL for generating avatars by ID
      final url = '$_baseUrl/$avatarId';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return AvatarData(
          id: avatarId,
          name: _generateAvatarName(avatarId),
          imageUrl: url,
          category: 'avatar',
          style: 'id-based',
          seed: avatarId,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Generates a random ID between min and max (inclusive)
  int _generateRandomId() {
    return _minId +
        (DateTime.now().millisecondsSinceEpoch % (_maxId - _minId + 1));
  }

  /// Fetches avatar by specific ID
  Future<AvatarData?> fetchAvatarById({
    required String avatarId,
  }) async {
    try {
      final url = '$_baseUrl/$avatarId';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return AvatarData(
          id: avatarId,
          name: _generateAvatarName(avatarId),
          imageUrl: url,
          category: 'avatar',
          style: 'id-based',
          seed: avatarId,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Gets available avatar ID range
  Map<String, int> getAvailableIdRange() {
    return {
      'min': _minId,
      'max': _maxId,
    };
  }

  /// Generates a human-readable name from avatar ID
  String _generateAvatarName(String avatarId) {
    // Generate a readable name based on avatar ID
    return 'Avatar #$avatarId';
  }

  /// Predefined avatar collections for quick access
  Future<List<AvatarData>> fetchPredefinedAvatars() async {
    try {
      List<AvatarData> avatars = [];

      // Create some predefined avatar IDs (0-100)
      final predefinedIds = [
        '4',
        '12',
        '23',
        '34',
        '45',
        '56',
        '67',
        '78',
        '89',
        '90',
        '15',
        '26',
        '37',
        '48',
        '59'
      ];

      for (int i = 0; i < predefinedIds.length; i++) {
        final avatarId = predefinedIds[i];
        final avatarData = await fetchAvatarById(
          avatarId: avatarId,
        );
        if (avatarData != null) {
          avatars.add(avatarData);
        }
      }

      return avatars;
    } catch (e) {
      throw Exception('Failed to fetch predefined avatars: $e');
    }
  }
}
