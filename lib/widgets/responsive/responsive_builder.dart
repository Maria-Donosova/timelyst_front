import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    return builder(context, screenSize);
  }
}

class OrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;

  const OrientationBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return builder(context, orientation);
  }
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget Function(BuildContext context, ScreenSize screenSize)? builder;

  const ResponsiveLayoutBuilder({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);

    if (builder != null) {
      return builder!(context, screenSize);
    }

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile ?? const SizedBox.shrink();
      case ScreenSize.tablet:
        return tablet ?? mobile ?? const SizedBox.shrink();
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
  }
}

class ScreenSizeWidget extends StatelessWidget {
  final Widget child;
  final ScreenSize screenSize;

  const ScreenSizeWidget({
    Key? key,
    required this.child,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentScreenSize = ResponsiveHelper.getScreenSize(context);
    return currentScreenSize == screenSize ? child : const SizedBox.shrink();
  }
}

class MobileLayout extends StatelessWidget {
  final Widget child;

  const MobileLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenSizeWidget(
      screenSize: ScreenSize.mobile,
      child: child,
    );
  }
}

class TabletLayout extends StatelessWidget {
  final Widget child;

  const TabletLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenSizeWidget(
      screenSize: ScreenSize.tablet,
      child: child,
    );
  }
}

class DesktopLayout extends StatelessWidget {
  final Widget child;

  const DesktopLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenSizeWidget(
      screenSize: ScreenSize.desktop,
      child: child,
    );
  }
}