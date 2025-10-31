import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isMobile => screenSize.width < Breakpoints.mobile;
  bool get isTablet => screenSize.width >= Breakpoints.mobile && screenSize.width < Breakpoints.tablet;
  bool get isDesktop => screenSize.width >= Breakpoints.tablet;
}

