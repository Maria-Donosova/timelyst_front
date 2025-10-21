import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';

enum TextType { display, body, caption }

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextType type;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.type = TextType.body,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveStyle;
    
    switch (type) {
      case TextType.display:
        effectiveStyle = _getDisplayStyle(context);
        break;
      case TextType.body:
        effectiveStyle = _getBodyStyle(context);
        break;
      case TextType.caption:
        effectiveStyle = _getCaptionStyle(context);
        break;
    }
    
    // Apply custom style if provided
    if (style != null) {
      effectiveStyle = effectiveStyle.merge(style);
    }
    
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getDisplayStyle(BuildContext context) {
    final fontSize = ResponsiveFontSizes.getDisplayLarge(context);
    final baseStyle = Theme.of(context).textTheme.displayLarge ?? 
                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    
    return baseStyle.copyWith(fontSize: fontSize);
  }

  TextStyle _getBodyStyle(BuildContext context) {
    final fontSize = ResponsiveFontSizes.getBodyLarge(context);
    final baseStyle = Theme.of(context).textTheme.bodyLarge ?? 
                     const TextStyle(fontSize: 16);
    
    return baseStyle.copyWith(fontSize: fontSize);
  }

  TextStyle _getCaptionStyle(BuildContext context) {
    final fontSize = ResponsiveFontSizes.getBodySmall(context);
    final baseStyle = Theme.of(context).textTheme.bodySmall ?? 
                     const TextStyle(fontSize: 14);
    
    return baseStyle.copyWith(fontSize: fontSize);
  }
}

class ResponsiveHeadline extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveHeadline(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      type: TextType.display,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveBodyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveBodyText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      type: TextType.body,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveCaptionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveCaptionText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      type: TextType.caption,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}