import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_values.dart';
import 'responsive_text.dart';

class ResponsiveCheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isLandscape;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? checkColor;

  const ResponsiveCheckboxRow({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isLandscape = false,
    this.textStyle,
    this.activeColor,
    this.checkColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    // Determine layout based on screen size and orientation
    bool isHorizontalLayout = screenSize != ScreenSize.mobile || 
                             (screenSize == ScreenSize.mobile && orientation == Orientation.landscape);
    
    if (isHorizontalLayout) {
      return _buildHorizontalLayout(context);
    } else {
      // Vertical layout for mobile portrait
      return _buildVerticalLayout(context);
    }
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          checkColor: checkColor ?? Colors.grey[800],
          activeColor: activeColor ?? const Color.fromRGBO(207, 204, 215, 100),
          visualDensity: VisualDensity.compact,
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: ResponsiveBodyText(
              label,
              style: textStyle ?? TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            checkColor: checkColor ?? Colors.grey[800],
            activeColor: activeColor ?? const Color.fromRGBO(207, 204, 215, 100),
            visualDensity: VisualDensity.compact,
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: ResponsiveBodyText(
                label,
                style: textStyle ?? TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveCheckboxList extends StatelessWidget {
  final List<CheckboxItem> items;
  final List<bool> values;
  final ValueChanged<int>? onToggle;
  final CheckboxListType listType;
  final CrossAxisAlignment alignment;

  const ResponsiveCheckboxList({
    Key? key,
    required this.items,
    required this.values,
    this.onToggle,
    this.listType = CheckboxListType.vertical,
    this.alignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    // Determine layout based on screen size and orientation
    CheckboxListType effectiveListType = listType;
    if (screenSize == ScreenSize.mobile && orientation == Orientation.landscape) {
      effectiveListType = CheckboxListType.horizontal;
    }
    
    switch (effectiveListType) {
      case CheckboxListType.vertical:
        return _buildVerticalList(context);
      case CheckboxListType.horizontal:
        return _buildHorizontalList(context);
      case CheckboxListType.grid:
        return _buildGridList(context);
    }
  }

  Widget _buildVerticalList(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: List.generate(
        items.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveSpacing.getFormFieldSpacing(context) * 0.5,
          ),
          child: ResponsiveCheckboxRow(
            label: items[index].label,
            value: index < values.length ? values[index] : false,
            onChanged: (value) => onToggle?.call(index),
            textStyle: items[index].textStyle,
            activeColor: items[index].activeColor,
            checkColor: items[index].checkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: ResponsiveSpacing.getFormFieldSpacing(context),
      runSpacing: ResponsiveSpacing.getFormFieldSpacing(context) * 0.5,
      children: List.generate(
        items.length,
        (index) => SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: ResponsiveCheckboxRow(
            label: items[index].label,
            value: index < values.length ? values[index] : false,
            onChanged: (value) => onToggle?.call(index),
            textStyle: items[index].textStyle,
            activeColor: items[index].activeColor,
            checkColor: items[index].checkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGridList(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3.0,
        crossAxisSpacing: ResponsiveSpacing.getFormFieldSpacing(context),
        mainAxisSpacing: ResponsiveSpacing.getFormFieldSpacing(context) * 0.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => ResponsiveCheckboxRow(
        label: items[index].label,
        value: index < values.length ? values[index] : false,
        onChanged: (value) => onToggle?.call(index),
        textStyle: items[index].textStyle,
        activeColor: items[index].activeColor,
        checkColor: items[index].checkColor,
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final orientation = MediaQuery.of(context).orientation;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return orientation == Orientation.landscape ? 2 : 1;
      case ScreenSize.tablet:
        return orientation == Orientation.landscape ? 3 : 2;
      case ScreenSize.desktop:
        return orientation == Orientation.landscape ? 4 : 3;
    }
  }
}

class CheckboxItem {
  final String label;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? checkColor;

  const CheckboxItem({
    required this.label,
    this.textStyle,
    this.activeColor,
    this.checkColor,
  });
}

enum CheckboxListType { vertical, horizontal, grid }

class ResponsiveTermsCheckbox extends StatelessWidget {
  final String termsText;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final TextStyle? textStyle;
  final VoidCallback? onTermsTap;

  const ResponsiveTermsCheckbox({
    Key? key,
    required this.termsText,
    required this.value,
    required this.onChanged,
    this.textStyle,
    this.onTermsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveCheckboxRow(
      label: termsText,
      value: value,
      onChanged: onChanged,
      textStyle: textStyle ?? TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: ResponsiveFontSizes.getBodySmall(context),
      ),
    );
  }
}

class ResponsiveCheckboxGroup extends StatelessWidget {
  final String? title;
  final List<CheckboxItem> items;
  final List<bool> values;
  final ValueChanged<int>? onToggle;
  final bool showDivider;

  const ResponsiveCheckboxGroup({
    Key? key,
    this.title,
    required this.items,
    required this.values,
    this.onToggle,
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: ResponsiveSpacing.getTitleSpacing(context)),
        ],
        ResponsiveCheckboxList(
          items: items,
          values: values,
          onToggle: onToggle,
        ),
        if (showDivider && items.isNotEmpty) ...[
          SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
          const Divider(),
        ],
      ],
    );
  }
}