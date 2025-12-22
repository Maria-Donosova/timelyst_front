import 'package:flutter/material.dart';

class CalendarColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const CalendarColorPicker({
    Key? key,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFF00E5FF), // Aqua
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
