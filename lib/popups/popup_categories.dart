import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/seal_selection_widget.dart';

class PopupCategories {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> translations,
    required List<Map<String, dynamic>> categories,
    required Function(Map<String, dynamic> item, String type) onItemSelected,
    required List<Map<String, dynamic>> selectedCategories,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void handleCategorySelected(Map<String, dynamic> category) {
              onItemSelected(category, 'category');
              setState(() {});
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryItem(
                          category,
                          translations,
                          context,
                          handleCategorySelected,
                          selectedCategories,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildCategoryItem(
      Map<String, dynamic> category,
      Map<String, dynamic> translations,
      BuildContext context,
      Function(Map<String, dynamic>) onCategorySelected,
      List<Map<String, dynamic>> selectedCategories,
      ) {
    final bool isSelected = selectedCategories.any((c) => c['id'] == category['id']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(category['name'] ?? translations['common']['noDataAvailable'] ?? "Unnamed Category"),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: Colors.blue)
              : Icon(Icons.circle_outlined),
          onTap: () {
            onCategorySelected(category);
          },
        ),
        if (category['children'] != null && category['children'] is List)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: (category['children'] as List)
                  .where((child) => child is Map<String, dynamic>)
                  .map((child) => _buildCategoryItem(
                child as Map<String, dynamic>,
                translations,
                context,
                onCategorySelected,
                selectedCategories,
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
