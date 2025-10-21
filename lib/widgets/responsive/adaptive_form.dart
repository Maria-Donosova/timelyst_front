import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';
import 'responsive_builder.dart';
import 'responsive_container.dart';
import 'responsive_text.dart';

class AdaptiveForm extends StatelessWidget {
  final Widget child;
  final bool centerForm;
  final EdgeInsets? padding;
  final GlobalKey<FormState>? formKey;

  const AdaptiveForm({
    Key? key,
    required this.child,
    this.centerForm = true,
    this.padding,
    this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final orientation = MediaQuery.of(context).orientation;
        if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
          // For mobile landscape, consider a two-column layout if screen is wide enough
          final screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth > 800) {
            return _buildTwoColumnLayout(context);
          }
        }
        
        // Default single column layout
        return _buildSingleColumnLayout(context);
      },
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    final effectivePadding = padding ?? ResponsivePadding.getFormPadding(context);
    
    return Form(
      key: formKey,
      child: Padding(
        padding: effectivePadding,
        child: centerForm 
            ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveWidths.getMaxFormWidth(context),
                  ),
                  child: child,
                ),
              )
            : child,
      ),
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Two-column layout for wide landscape screens
          return Form(
            key: formKey,
            child: Padding(
              padding: padding ?? ResponsivePadding.getFormPadding(context),
              child: _buildTwoColumnContent(context),
            ),
          );
        } else {
          // Fall back to single column
          return _buildSingleColumnLayout(context);
        }
      },
    );
  }

  Widget _buildTwoColumnContent(BuildContext context) {
    // This is a placeholder for two-column layout
    // In a real implementation, you would need to extract the form fields
    // and distribute them between two columns
    return Column(
      children: [
        ResponsiveHeadline(
          'Wide Screen Layout',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
        child,
      ],
    );
  }
}

class ResponsiveFormLayout extends StatelessWidget {
  final List<Widget> children;
  final FormLayoutType layoutType;
  final CrossAxisAlignment alignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveFormLayout({
    Key? key,
    required this.children,
    this.layoutType = FormLayoutType.column,
    this.alignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final orientation = MediaQuery.of(context).orientation;
        switch (layoutType) {
          case FormLayoutType.column:
            return _buildColumnLayout(context, screenSize, orientation);
          case FormLayoutType.row:
            return _buildRowLayout(context, screenSize, orientation);
          case FormLayoutType.grid:
            return _buildGridLayout(context, screenSize, orientation);
          case FormLayoutType.adaptive:
            return _buildAdaptiveLayout(context, screenSize, orientation);
        }
      },
    );
  }

  Widget _buildColumnLayout(BuildContext context, ScreenSize screenSize, Orientation orientation) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );
  }

  Widget _buildRowLayout(BuildContext context, ScreenSize screenSize, Orientation orientation) {
    // On mobile in portrait, switch to column layout
    if (screenSize == ScreenSize.mobile && orientation == Orientation.portrait) {
      return _buildColumnLayout(context, screenSize, orientation);
    }
    
    return Row(
      crossAxisAlignment: alignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children
          .map((child) => Flexible(child: child))
          .expand((child) => [
                child,
                SizedBox(width: ResponsiveSpacing.getFormFieldSpacing(context)),
              ])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context, ScreenSize screenSize, Orientation orientation) {
    final crossAxisCount = _getCrossAxisCount(screenSize, orientation);
    final childAspectRatio = _getChildAspectRatio(screenSize, orientation);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: ResponsiveSpacing.getFormFieldSpacing(context),
        mainAxisSpacing: ResponsiveSpacing.getFormFieldSpacing(context),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildAdaptiveLayout(BuildContext context, ScreenSize screenSize, Orientation orientation) {
    // Adaptive layout based on screen size and content
    if (screenSize == ScreenSize.mobile) {
      if (orientation == Orientation.landscape && children.length >= 4) {
        // Two columns for mobile landscape with enough content
        return _buildTwoColumnAdaptive(context);
      }
      return _buildColumnLayout(context, screenSize, orientation);
    } else if (screenSize == ScreenSize.tablet) {
      if (children.length >= 3) {
        return _buildGridLayout(context, screenSize, orientation);
      }
      return _buildRowLayout(context, screenSize, orientation);
    } else {
      // Desktop
      if (children.length >= 4) {
        return _buildGridLayout(context, screenSize, orientation);
      }
      return _buildRowLayout(context, screenSize, orientation);
    }
  }

  Widget _buildTwoColumnAdaptive(BuildContext context) {
    final midPoint = (children.length / 2).ceil();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.take(midPoint).toList(),
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getFormFieldSpacing(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.skip(midPoint).toList(),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(ScreenSize screenSize, Orientation orientation) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return orientation == Orientation.landscape ? 2 : 1;
      case ScreenSize.tablet:
        return orientation == Orientation.landscape ? 3 : 2;
      case ScreenSize.desktop:
        return orientation == Orientation.landscape ? 4 : 3;
    }
  }

  double _getChildAspectRatio(ScreenSize screenSize, Orientation orientation) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return orientation == Orientation.landscape ? 2.5 : 1.5;
      case ScreenSize.tablet:
        return orientation == Orientation.landscape ? 2.0 : 1.8;
      case ScreenSize.desktop:
        return orientation == Orientation.landscape ? 2.2 : 2.0;
    }
  }
}

enum FormLayoutType { column, row, grid, adaptive }

class ResponsiveFormSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final bool showDivider;

  const ResponsiveFormSection({
    Key? key,
    this.title,
    this.subtitle,
    required this.children,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          ResponsiveHeadline(
            title!,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: ResponsiveSpacing.getTitleSpacing(context)),
        ],
        if (subtitle != null) ...[
          ResponsiveBodyText(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
        ],
        ...children,
        if (showDivider && children.isNotEmpty) ...[
          SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
          const Divider(),
        ],
      ],
    );
  }
}