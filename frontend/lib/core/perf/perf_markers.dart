import 'package:flutter/widgets.dart';

class PerfMarkers {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final build = t.buildDuration.inMilliseconds;
        final raster = t.rasterDuration.inMilliseconds;
        if (build > 16 || raster > 16) {
          // Print slow frame markers for debugging (replace with logging service if desired)
          // ignore: avoid_print
          print('[Perf] Slow frame: build ${build}ms, raster ${raster}ms');
        }
      }
    });
  }
}

