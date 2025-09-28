import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  // Screen size categories
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < largeDesktopBreakpoint) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  // Responsive values
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(responsive(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 40.0,
    ));
  }

  // Responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    return EdgeInsets.all(responsive(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    ));
  }

  // Responsive font sizes
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
      largeDesktop: largeDesktop ?? mobile * 1.3,
    );
  }

  // Grid columns based on screen size
  static int getGridColumns(BuildContext context, {int maxColumns = 4}) {
    return responsive(
      context,
      mobile: 1,
      tablet: 2,
      desktop: maxColumns.clamp(1, 3),
      largeDesktop: maxColumns,
    );
  }

  // Drawer width based on screen size
  static double getDrawerWidth(BuildContext context) {
    return responsive(
      context,
      mobile: MediaQuery.of(context).size.width * 0.85,
      tablet: 320.0,
      desktop: 280.0,
      largeDesktop: 320.0,
    );
  }

  // App bar height
  static double getAppBarHeight(BuildContext context) {
    return responsive(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
      largeDesktop: kToolbarHeight + 20,
    );
  }

  // Card elevation
  static double getCardElevation(BuildContext context) {
    return responsive(
      context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
      largeDesktop: 8.0,
    );
  }

  // Icon sizes
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    return responsive(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
      largeDesktop: baseSize * 1.3,
    );
  }

  // Button sizes
  static Size getButtonSize(BuildContext context) {
    return Size(
      responsive(
        context,
        mobile: 120.0,
        tablet: 140.0,
        desktop: 160.0,
        largeDesktop: 180.0,
      ),
      responsive(
        context,
        mobile: 44.0,
        tablet: 48.0,
        desktop: 52.0,
        largeDesktop: 56.0,
      ),
    );
  }

  // Safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Get pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Check if device has notch/cutout
  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 24;
  }

  // Adaptive layout constraints
  static BoxConstraints getAdaptiveConstraints(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BoxConstraints(
      maxWidth: width > desktopBreakpoint ? desktopBreakpoint : width,
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

// Extension for easier usage
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLargeDesktop => ResponsiveUtils.isLargeDesktop(this);

  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) =>
      ResponsiveUtils.responsive(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        largeDesktop: largeDesktop,
      );
}
