import 'package:flutter/material.dart';

class SelectedFiltersBar extends StatelessWidget {
  final List<Map<String, dynamic>> selectedSeals;
  final List<Map<String, dynamic>> selectedCategories;
  final void Function(Map<String, dynamic> item, String type) onRemove;

  const SelectedFiltersBar({
    super.key,
    required this.selectedSeals,
    required this.selectedCategories,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedSeals.map((s) => _Chip(
            label: "${s['name']}: ${s['state']}",
            onTap: () => onRemove(s, 'seal'),
          )),
          ...selectedCategories.map((c) => _Chip(
            label: c['name']?.toString() ?? '',
            onTap: () => onRemove(c, 'category'),
          )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.close, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
