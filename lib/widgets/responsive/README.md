# Responsive System for Flutter

This responsive system provides a comprehensive set of widgets and utilities to create adaptive layouts that work seamlessly across mobile, tablet, and desktop devices.

## Features

- **Breakpoint-based design** with smooth transitions between screen sizes
- **Orientation awareness** for mobile devices
- **Reusable components** for consistent responsive behavior
- **Easy integration** with existing Flutter widgets

## Breakpoints

- **Mobile**: < 600px width
- **Tablet**: 600px - 1024px width  
- **Desktop**: > 1024px width

## Quick Start

### 1. Import the responsive widgets

```dart
import 'package:your_app/widgets/responsive/responsive_widgets.dart';
```

### 2. Basic Usage

```dart
class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: CustomAppBar(),
      body: AdaptiveForm(
        child: Column(
          children: [
            ResponsiveHeadline(
              'Your Title',
              textAlign: TextAlign.center,
            ),
            ResponsiveFormField(
              labelText: 'Email',
              controller: _emailController,
              validator: ResponsiveFormValidator.validateEmail,
            ),
            ResponsiveButton(
              text: 'Submit',
              onPressed: () {
                // Handle button press
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Core Widgets

### ResponsiveContainer

A container that automatically adjusts padding and max width based on screen size.

```dart
ResponsiveContainer(
  child: YourContent(),
)
```

### AdaptiveForm

A form container that adjusts layout based on screen size and orientation.

```dart
AdaptiveForm(
  formKey: _formKey,
  child: YourFormFields(),
)
```

### ResponsiveText

Text that scales appropriately across devices.

```dart
ResponsiveText(
  'Your text',
  type: TextType.display, // or TextType.body, TextType.caption
  textAlign: TextAlign.center,
)
```

### ResponsiveFormField

Form field that adjusts width and padding.

```dart
ResponsiveFormField(
  labelText: 'Email',
  controller: _emailController,
  validator: ResponsiveFormValidator.validateEmail,
)
```

### ResponsiveButton

Button that adapts its size and layout.

```dart
ResponsiveButton(
  text: 'Submit',
  onPressed: () {},
  type: ButtonType.primary, // or ButtonType.secondary, ButtonType.text
  isLoading: false,
)
```

### ResponsiveCheckboxRow

Checkbox that adapts layout based on screen size.

```dart
ResponsiveCheckboxRow(
  label: 'I agree to the terms',
  value: _isChecked,
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

## Helper Classes

### ResponsiveHelper

Utility functions for responsive design.

```dart
// Get current screen size
final screenSize = ResponsiveHelper.getScreenSize(context);

// Check if device is mobile
final isMobile = ResponsiveHelper.isMobile(context);

// Get responsive value
final value = ResponsiveHelper.getValue(
  context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
);
```

### ResponsiveFormValidator

Common validation functions.

```dart
// Validate email
validator: ResponsiveFormValidator.validateEmail

// Validate password
validator: ResponsiveFormValidator.validatePassword

// Validate name
validator: ResponsiveFormValidator.validateName
```

## Responsive Values

The system provides consistent values for different screen sizes:

### Padding

- Mobile: 16px horizontal
- Tablet: 24px horizontal
- Desktop: 32px horizontal

### Font Sizes

- Display text: 24px → 28px → 32px
- Body text: 16px → 16px → 18px
- Caption text: 14px → 14px → 16px

### Spacing

- Form field spacing: 16px → 20px → 24px
- Section spacing: 24px → 32px → 40px

## Layout Patterns

### Mobile Layout

- Full-width form fields
- Compact spacing
- Optimized for touch interaction

### Tablet Layout

- Form width limited to 70% of screen
- Increased spacing
- Balanced touch and mouse interaction

### Desktop Layout

- Form limited to 500px max width
- Largest spacing
- Optimized for mouse interaction

## Migration Guide

To convert an existing screen to use the responsive system:

1. Replace `Container` with `ResponsiveContainer`
2. Replace `Text` with `ResponsiveText`
3. Replace `ElevatedButton` with `ResponsiveButton`
4. Replace `TextFormField` with `ResponsiveFormField`
5. Replace fixed padding with `ResponsivePadding`
6. Replace fixed spacing with `ResponsiveSpacing`

### Before (Fixed Layout)

```dart
class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 120.0, left: 30, right: 30),
        child: Form(
          child: Column(
            children: [
              Text(
                'Tell us more about yourself',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              TextFormField(...),
              ElevatedButton(...),
            ],
          ),
        ),
      ),
    );
  }
}
```

### After (Responsive Layout)

```dart
class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: AdaptiveForm(
        child: Column(
          children: [
            ResponsiveHeadline(
              'Tell us more about yourself',
              textAlign: TextAlign.center,
            ),
            ResponsiveFormField(...),
            ResponsiveButton(...),
          ],
        ),
      ),
    );
  }
}
```

## Testing

Test your responsive layouts on different screen sizes:

1. Use Chrome DevTools for web testing
2. Test on actual devices when possible
3. Check both portrait and landscape orientations
4. Verify accessibility at all screen sizes

## Best Practices

1. **Always use responsive widgets** instead of fixed-size widgets
2. **Test on multiple screen sizes** during development
3. **Consider orientation** for mobile devices
4. **Use consistent spacing** with the helper classes
5. **Keep layouts simple** and avoid overly complex responsive logic
6. **Ensure accessibility** with proper text scaling and contrast

## Troubleshooting

### Common Issues

1. **Widget not resizing**: Ensure you're using responsive widgets
2. **Text overflow**: Check if you're using `ResponsiveText`
3. **Layout breaks on tablet**: Test with tablet breakpoints
4. **Button too small on mobile**: Use `ResponsiveButton` instead of `ElevatedButton`

### Debugging

Use the `ResponsiveBuilder` to check current screen size:

```dart
ResponsiveBuilder(
  builder: (context, screenSize) {
    debugPrint('Current screen size: $screenSize');
    return YourWidget();
  },
)