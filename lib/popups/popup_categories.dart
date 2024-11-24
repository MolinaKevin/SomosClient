import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupCategories {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> translations,
    required List<Map<String, dynamic>> categories,
    required Function(Map<String, dynamic> category) onCategorySelected,
    required List<Map<String, dynamic>> selectedCategories,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        // Usamos StatefulBuilder para manejar el estado dentro del modal
        return StatefulBuilder(
          builder: (context, setState) {
            void handleCategorySelection(Map<String, dynamic> category) {
              onCategorySelected(category);
              // Actualizamos el estado local para reconstruir el widget
              setState(() {});
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryItem(
                    category,
                    translations,
                    context,
                    handleCategorySelection,
                    selectedCategories,
                  );
                },
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
      Function(Map<String, dynamic> category) onCategorySelected,
      List<Map<String, dynamic>> selectedCategories,
      ) {
    bool isSelected = selectedCategories.any((c) => c['id'] == category['id']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(category['name']),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: Colors.blue)
              : Icon(Icons.circle_outlined),
          onTap: () {
            onCategorySelected(category);
          },
        ),
        if (category['children'] != null && category['children'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: category['children'].map<Widget>((child) {
                return _buildCategoryItem(
                  child,
                  translations,
                  context,
                  onCategorySelected,
                  selectedCategories,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
