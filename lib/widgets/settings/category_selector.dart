import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart' as app_cats;

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: app_cats.categories.map((label) {
        final color = app_cats.catColor(label);
        final isSelected = selectedCategory.toLowerCase() == label.toLowerCase();

        return InkWell(
          onTap: () => onCategorySelected(label.toLowerCase()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
