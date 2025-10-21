import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';
import 'responsive_text.dart';

enum ButtonType { primary, secondary, text }

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? customWidth;
  final Widget? icon;
  final MainAxisSize? mainAxisSize;

  const ResponsiveButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.customWidth,
    this.icon,
    this.mainAxisSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    // Determine button width based on screen size
    double buttonWidth;
    EdgeInsets buttonPadding;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        buttonWidth = double.infinity;
        buttonPadding = const EdgeInsets.symmetric(vertical: 16);
        break;
      case ScreenSize.tablet:
        buttonWidth = MediaQuery.of(context).size.width * 0.7;
        buttonPadding = const EdgeInsets.symmetric(vertical: 18, horizontal: 24);
        break;
      case ScreenSize.desktop:
        buttonWidth = customWidth ?? 300;
        buttonPadding = const EdgeInsets.symmetric(vertical: 20, horizontal: 32);
        break;
    }
    
    // Adjust for landscape orientation on mobile
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      buttonPadding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    }
    
    // Determine button style based on type
    ButtonStyle buttonStyle;
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = _buildLoadingIndicator(context);
    } else if (icon != null) {
      buttonChild = _buildButtonWithIcon(context);
    } else {
      buttonChild = _buildButtonText(context);
    }
    
    switch (type) {
      case ButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.shadow,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
        return _buildButton(
          context,
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
          buttonWidth,
        );
        
      case ButtonType.secondary:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        );
        return _buildButton(
          context,
          OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
          buttonWidth,
        );
        
      case ButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: buttonPadding,
        );
        return _buildButton(
          context,
          TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
          buttonWidth,
        );
    }
  }

  Widget _buildButtonText(BuildContext context) {
    return ResponsiveText(
      text,
      type: TextType.body,
      style: TextStyle(
        color: type == ButtonType.primary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildButtonWithIcon(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        _buildButtonText(context),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == ButtonType.primary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Widget button, double width) {
    return Container(
      width: width,
      child: button,
    );
  }
}

class ResponsiveButtonGroup extends StatelessWidget {
  final List<ResponsiveButton> buttons;
  final ButtonGroupLayout layout;
  final CrossAxisAlignment alignment;

  const ResponsiveButtonGroup({
    Key? key,
    required this.buttons,
    this.layout = ButtonGroupLayout.vertical,
    this.alignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    // Determine layout based on screen size and orientation
    ButtonGroupLayout effectiveLayout = layout;
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      effectiveLayout = ButtonGroupLayout.horizontal;
    }
    
    switch (effectiveLayout) {
      case ButtonGroupLayout.vertical:
        return Column(
          crossAxisAlignment: alignment,
          children: buttons
              .map((button) => Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveSpacing.getButtonSpacing(context),
                    ),
                    child: button,
                  ))
              .toList(),
        );
      case ButtonGroupLayout.horizontal:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons
              .map((button) => Padding(
                    padding: EdgeInsets.only(
                      right: ResponsiveSpacing.getButtonSpacing(context),
                    ),
                    child: Flexible(child: button),
                  ))
              .toList(),
        );
    }
  }
}

enum ButtonGroupLayout { vertical, horizontal }

class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final double? iconSize;
  final Color? color;

  const ResponsiveIconButton({
    Key? key,
    required this.icon,
    this.tooltip,
    required this.onPressed,
    this.iconSize,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    double effectiveIconSize = iconSize ?? 24;
    if (iconSize == null) {
      switch (screenSize) {
        case ScreenSize.mobile:
          effectiveIconSize = 24;
          break;
        case ScreenSize.tablet:
          effectiveIconSize = 26;
          break;
        case ScreenSize.desktop:
          effectiveIconSize = 28;
          break;
      }
    }
    
    return IconButton(
      icon: Icon(
        icon,
        size: effectiveIconSize,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}