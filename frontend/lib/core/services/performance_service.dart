import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration _cacheExpiration = Duration(hours: 24);

  final Map<String, _CacheEntry> _memoryCache = {};
  Timer? _cacheCleanupTimer;

  /// Initialize performance service
  void initialize() {
    _startCacheCleanup();
    _setupMemoryWarningHandler();
  }

  /// Dispose resources
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _memoryCache.clear();
  }

  /// Cache data in memory with expiration
  void cacheData(String key, dynamic data) {
    _memoryCache[key] = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      size: _calculateSize(data),
    );

    _enforceMemoryLimit();
  }

  /// Retrieve cached data
  T? getCachedData<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().difference(entry.timestamp) > _cacheExpiration) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Remove specific cache entry
  void removeCacheEntry(String key) {
    _memoryCache.remove(key);
  }

  /// Clear all cache
  void clearCache() {
    _memoryCache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    int totalSize = 0;
    for (final entry in _memoryCache.values) {
      totalSize += entry.size;
    }

    return {
      'entries': _memoryCache.length,
      'totalSize': totalSize,
      'maxSize': _maxCacheSize,
      'utilizationPercent':
          (totalSize / _maxCacheSize * 100).toStringAsFixed(1),
    };
  }

  /// Preload critical resources
  static Future<void> preloadCriticalResources(BuildContext context) async {
    // Preload common images
    const imagePaths = [
      'assets/images/logo.png',
      'assets/images/placeholder.png',
    ];

    for (final path in imagePaths) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to preload image: $path');
        }
      }
    }
  }

  /// Optimize widget build performance
  static Widget optimizedBuilder({
    required Widget Function() builder,
    Duration debounceTime = const Duration(milliseconds: 16),
  }) {
    return _DebouncedBuilder(
      builder: builder,
      debounceTime: debounceTime,
    );
  }

  /// Memory usage optimization
  static void optimizeMemoryUsage() {
    // Force garbage collection in debug mode
    if (kDebugMode) {
      // This is mainly for debugging; avoid in production
      debugPrint('Memory optimization requested');
    }

    // Clear image cache if memory is low
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Check if device has limited resources
  static bool get isLowEndDevice {
    // This is a simplified check; you might want to use device_info_plus
    // to get more detailed hardware information
    return Platform.isAndroid; // Placeholder logic
  }

  /// Start periodic cache cleanup
  void _startCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupExpiredEntries();
    });
  }

  /// Clean up expired cache entries
  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _memoryCache.entries) {
      if (now.difference(entry.value.timestamp) > _cacheExpiration) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint('Cleaned up ${keysToRemove.length} expired cache entries');
    }
  }

  /// Enforce memory cache size limit
  void _enforceMemoryLimit() {
    int totalSize = 0;
    for (final entry in _memoryCache.values) {
      totalSize += entry.size;
    }

    if (totalSize > _maxCacheSize) {
      // Remove oldest entries until under limit
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      for (final entry in sortedEntries) {
        _memoryCache.remove(entry.key);
        totalSize -= entry.value.size;

        if (totalSize <= _maxCacheSize * 0.8) break; // Leave some headroom
      }
    }
  }

  /// Calculate approximate size of data
  int _calculateSize(dynamic data) {
    if (data is String) {
      return data.length * 2; // Approximate UTF-16 encoding
    } else if (data is List) {
      return data.length * 8; // Rough estimate
    } else if (data is Map) {
      return data.length * 16; // Rough estimate
    }
    return 64; // Default estimate
  }

  /// Setup memory warning handler
  void _setupMemoryWarningHandler() {
    // In a real app, you might use platform channels to listen for memory warnings
    // For now, this is a placeholder
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final int size;

  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.size,
  });
}

class _DebouncedBuilder extends StatefulWidget {
  final Widget Function() builder;
  final Duration debounceTime;

  const _DebouncedBuilder({
    required this.builder,
    required this.debounceTime,
  });

  @override
  State<_DebouncedBuilder> createState() => _DebouncedBuilderState();
}

class _DebouncedBuilderState extends State<_DebouncedBuilder> {
  Timer? _debounceTimer;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    _cachedWidget = widget.builder();
  }

  @override
  void didUpdateWidget(_DebouncedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      if (mounted) {
        setState(() {
          _cachedWidget = widget.builder();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget ?? const SizedBox.shrink();
  }
}

