import 'package:flutter/material.dart';
import '../widgets/seal_selection_widget.dart';

class PopupSeals {
  static void show({
    required BuildContext context,
    required List<Map<String, dynamic>> seals,
    required List<Map<String, dynamic>> selectedSeals,
    required Function(List<Map<String, dynamic>> updatedSeals) onSealStateChanged,
  }) {
    final sealsWithState = seals.map((seal) {
      final existing = selectedSeals.firstWhere(
            (s) => s['id'] == seal['id'],
        orElse: () => {'state': 'none'},
      );
      return {
        ...seal,
        'state': existing['state'] ?? 'none',
      };
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SealSelectionWidget(
            sealsWithState: sealsWithState,
            onSealStateChanged: onSealStateChanged,
          ),
        );
      },
    );
  }
}
