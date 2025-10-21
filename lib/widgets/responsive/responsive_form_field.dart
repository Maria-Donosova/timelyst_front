import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';
import 'responsive_text.dart';

class ResponsiveFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;
  final VoidCallback? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool autocorrect;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? initialValue;

  const ResponsiveFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    required this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.obscureText = false,
    this.autocorrect = true,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    // Determine field width based on screen size
    double fieldWidth;
    EdgeInsets fieldPadding;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        fieldWidth = double.infinity;
        fieldPadding = const EdgeInsets.symmetric(vertical: 4);
        break;
      case ScreenSize.tablet:
        fieldWidth = MediaQuery.of(context).size.width * 0.7;
        fieldPadding = const EdgeInsets.symmetric(vertical: 6);
        break;
      case ScreenSize.desktop:
        fieldWidth = 500;
        fieldPadding = const EdgeInsets.symmetric(vertical: 8);
        break;
    }
    
    // Adjust for landscape orientation on mobile
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      fieldPadding = const EdgeInsets.symmetric(vertical: 2);
    }
    
    return Container(
      width: fieldWidth,
      padding: fieldPadding,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: (value) => onFieldSubmitted?.call(),
        focusNode: focusNode,
        obscureText: obscureText,
        autocorrect: autocorrect,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        style: _getTextStyle(context),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: _getContentPadding(context),
          border: _getInputBorder(),
          enabledBorder: _getInputBorder(),
          focusedBorder: _getInputBorder().copyWith(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: _getInputBorder().copyWith(
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: _getInputBorder().copyWith(
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = ResponsiveFontSizes.getBodyLarge(context);
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: fontSize,
    ) ?? TextStyle(fontSize: fontSize);
  }

  EdgeInsets _getContentPadding(BuildContext context) {
    final spacing = ResponsiveSpacing.getFormFieldSpacing(context);
    return EdgeInsets.symmetric(
      horizontal: spacing * 0.75,
      vertical: spacing * 0.5,
    );
  }

  InputBorder _getInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    );
  }
}

class ResponsiveFormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide a value.';
    }
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide a value.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    const pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a strong password with uppercase, lowercase, number, and special character.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide a value.';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName.';
    }
    return null;
  }
}

class FormFieldGroup extends StatelessWidget {
  final List<Widget> fields;
  final String? title;
  final String? subtitle;

  const FormFieldGroup({
    Key? key,
    required this.fields,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          ResponsiveHeadline(
            title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: ResponsiveSpacing.getTitleSpacing(context) * 0.5),
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
        ...fields,
      ],
    );
  }
}