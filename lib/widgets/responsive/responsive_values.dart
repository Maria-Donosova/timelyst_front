import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsivePadding {
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 32),
    );
  }

  static EdgeInsets getVerticalPadding(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: const EdgeInsets.symmetric(vertical: 16),
      tablet: const EdgeInsets.symmetric(vertical: 24),
      desktop: const EdgeInsets.symmetric(vertical: 32),
    );
  }

  static EdgeInsets getFormPadding(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      return const EdgeInsets.only(top: 60, left: 16, right: 16);
    }
    
    return ResponsiveHelper.getValue(
      context,
      mobile: const EdgeInsets.only(top: 120, left: 16, right: 16),
      tablet: const EdgeInsets.only(top: 120, left: 24, right: 24),
      desktop: const EdgeInsets.only(top: 120, left: 32, right: 32),
    );
  }
}

class ResponsiveSpacing {
  static double getFormFieldSpacing(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
  }

  static double getSectionSpacing(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 24,
      tablet: 32,
      desktop: 40,
    );
  }

  static double getButtonSpacing(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
  }

  static double getTitleSpacing(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
  }
}

class ResponsiveFontSizes {
  static double getDisplayLarge(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 24,
      tablet: 28,
      desktop: 32,
    );
  }

  static double getBodyLarge(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 16,
      tablet: 16,
      desktop: 18,
    );
  }

  static double getBodySmall(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 14,
      tablet: 14,
      desktop: 16,
    );
  }

  static double getButtonFontSize(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 16,
      tablet: 16,
      desktop: 18,
    );
  }
}

class ResponsiveWidths {
  static double getFormWidth(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return MediaQuery.of(context).size.width * 0.7;
      case ScreenSize.desktop:
        return 500;
    }
  }

  static double getButtonWidth(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return MediaQuery.of(context).size.width * 0.7;
      case ScreenSize.desktop:
        return 300;
    }
  }

  static double getMaxFormWidth(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
      case ScreenSize.tablet:
        return double.infinity;
      case ScreenSize.desktop:
        return 500;
    }
  }
}

class ResponsiveHeights {
  static double getButtonHeight(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      return 44;
    }
    
    return ResponsiveHelper.getValue(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }

  static double getFormFieldHeight(BuildContext context) {
    return ResponsiveHelper.getValue(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }
}