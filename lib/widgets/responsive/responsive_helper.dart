import 'package:flutter/material.dart';

enum ScreenSize {
  mobile,    // < 600px
  tablet,    // 600px - 1024px
  desktop,   // > 1024px
}

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

class ResponsiveHelper {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) {
      return ScreenSize.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
    }
  }

  static double lerp(double start, double end, double progress) {
    return start + (end - start) * progress;
  }

  static double getResponsiveValue(
    BuildContext context, {
    required double mobileValue,
    double? tabletValue,
    double? desktopValue,
  }) {
    final screenSize = getScreenSize(context);
    final width = MediaQuery.of(context).size.width;

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileValue;
      case ScreenSize.tablet:
        if (tabletValue != null) return tabletValue;
        // Interpolate between mobile and desktop if tablet value not provided
        final progress = (width - Breakpoints.mobile) / (Breakpoints.tablet - Breakpoints.mobile);
        return lerp(mobileValue, desktopValue ?? mobileValue, progress);
      case ScreenSize.desktop:
        if (desktopValue != null) return desktopValue;
        return mobileValue;
    }
  }
}