import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final Alignment alignment;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.center,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsivePadding.getFormPadding(context);
    final effectiveMaxWidth = maxWidth ?? ResponsiveWidths.getMaxFormWidth(context);

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      color: color,
      decoration: decoration,
      child: Padding(
        padding: effectivePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveMaxWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;

  const ResponsiveCenter({
    Key? key,
    required this.child,
    this.widthFactor,
    this.heightFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    // Don't center on mobile to use full width
    if (screenSize == ScreenSize.mobile) {
      return child;
    }
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveWidths.getFormWidth(context),
        ),
        child: child,
      ),
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: ResponsiveContainer(
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons != null ? [persistentFooterButtons!] : null,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

class ResponsivePaddingWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool responsive;

  const ResponsivePaddingWidget({
    Key? key,
    required this.child,
    this.padding,
    this.responsive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectivePadding = responsive && padding == null
        ? ResponsivePadding.getHorizontalPadding(context)
        : padding ?? EdgeInsets.zero;

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}

class ResponsiveSpacingWidget extends StatelessWidget {
  final double height;
  final double width;

  const ResponsiveSpacingWidget({
    Key? key,
    this.height = 1,
    this.width = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSpacing.getFormFieldSpacing(context);
    return SizedBox(
      height: height * spacing,
      width: width * spacing,
    );
  }
}