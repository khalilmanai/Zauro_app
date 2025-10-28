import 'package:dio/dio.dart';
import '../models/avatar_api_models.dart';

class AvatarService {
  static const String _baseUrl = 'https://avatar.iran.liara.run/public';
  static const int _minId = 0;
  static const int _maxId = 100;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );

  /// Fetches a batch of random avatars from Iran Liara API
  Future<List<AvatarData>> fetchRandomAvatars({int count = 5}) async {
    try {
      // Generate all IDs first
      final ids = List.generate(count, (_) => _generateRandomId());

      // Fetch all avatars in parallel for faster loading
      final futures = ids.map((id) => _generateAvatarFast(id.toString()));
      final results = await Future.wait(futures);

      // Filter out null results
      return results.whereType<AvatarData>().toList();
    } catch (e) {
      throw Exception('Failed to fetch avatars: $e');
    }
  }

  /// Fetches additional avatars for lazy loading
  Future<List<AvatarData>> fetchMoreAvatars(
      {int count = 5, int offset = 0}) async {
    try {
      // Generate all IDs with offset first
      final ids = List.generate(
        count,
        (i) => _generateRandomIdWithOffset(offset + i),
      );

      // Fetch all avatars in parallel for faster loading
      final futures = ids.map((id) => _generateAvatarFast(id.toString()));
      final results = await Future.wait(futures);

      // Filter out null results
      return results.whereType<AvatarData>().toList();
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

  /// Fast avatar generation without API verification (optimized)
  /// Since avatar URLs are predictable, we don't need to verify each one
  Future<AvatarData?> _generateAvatarFast(String avatarId) async {
    try {
      final url = '$_baseUrl/$avatarId';

      // Return avatar data immediately without verification
      // The image will be validated when CachedNetworkImage loads it
      return AvatarData(
        id: avatarId,
        name: _generateAvatarName(avatarId),
        imageUrl: url,
        category: 'avatar',
        style: 'id-based',
        seed: avatarId,
      );
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

  /// Predefined avatar collections for quick access (optimized with parallel loading)
  Future<List<AvatarData>> fetchPredefinedAvatars() async {
    try {
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
        '59',
        '7',
        '18',
        '29',
        '40',
        '51',
      ];

      // Fetch all avatars in parallel instead of sequentially (MUCH faster!)
      final futures = predefinedIds.map((id) => _generateAvatarFast(id));
      final results = await Future.wait(futures);

      // Filter out null results
      return results.whereType<AvatarData>().toList();
    } catch (e) {
      throw Exception('Failed to fetch predefined avatars: $e');
    }
  }
}
