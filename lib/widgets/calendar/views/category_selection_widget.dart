import 'package:flutter/material.dart';
import '../../shared/categories.dart';

class CategorySelectionWidget extends StatefulWidget {
  final String initialCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionWidget({
    Key? key,
    required this.initialCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionWidget> createState() =>
      _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    print("Entering CategorySelectionWidget");
    return InkWell(
      onTap: () => _showCategoryDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: catColor(_selectedCategory),
            radius: 8,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedCategory,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Category',
            style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: catColor(category),
                  radius: 10,
                ),
                title: Text(category),
                onTap: () {
                  Navigator.of(context).pop(category);
                },
                selected: _selectedCategory == category,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
      widget.onCategorySelected(result);
    }
  }
}
