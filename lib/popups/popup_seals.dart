import 'package:flutter/material.dart';
import '../widgets/seal_selection_widget.dart';

class PopupSeals {
  /// Abre el modal para elegir estados de sellos (none/partial/full).
  ///
  /// [seals] viene de `SealService.fetchSeals()` (mock o API) y trae al menos:
  ///   - { id, name, slug, asset_base? }
  /// [selectedSeals] es la selección actual:
  ///   - { id, name?, state: 'none'|'partial'|'full' }
  static void show({
    required BuildContext context,
    required List<Map<String, dynamic>> seals,
    required List<Map<String, dynamic>> selectedSeals,
    required ValueChanged<List<Map<String, dynamic>>> onSealStateChanged,
  }) {
    final selById = <int, String>{
      for (final s in selectedSeals)
        if (s['id'] != null)
          (s['id'] as int): _normState((s['state'] ?? 'none').toString()),
    };

    final sealsWithState = seals
        .map((seal) {
      final id = seal['id'] as int;
      final state = selById[id] ?? 'none';
      return {...seal, 'state': state};
    })
        .toList()
      ..sort((a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final maxH = MediaQuery.of(context).size.height * 0.55;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SealSelectionWidget(
              sealsWithState: sealsWithState,

              // 🔴 Cambios en vivo
              onSealStateChanged: (updated) {
                final picked = _onlyActive(updated);
                onSealStateChanged(picked);
              },

              // ✅ Aplicar: cierra modal con selección activa
              onApply: (updated) {
                final picked = _onlyActive(updated);
                onSealStateChanged(picked);
                Navigator.of(context).pop();
              },

              // 🧹 Limpiar todo
              onClearAll: () {
                onSealStateChanged(const []);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  static List<Map<String, dynamic>> _onlyActive(List<Map<String, dynamic>> list) {
    return list
        .where((s) => _normState((s['state'] ?? 'none').toString()) != 'none')
        .map((s) => {
      'id': s['id'],
      'name': s['name'],
      'state': _normState((s['state'] ?? 'none').toString()),
    })
        .toList();
  }

  static String _normState(String raw) {
    switch (raw.toLowerCase()) {
      case 'verified':
        return 'full';
      case 'candidate':
        return 'partial';
      case 'full':
      case 'partial':
        return raw.toLowerCase();
      default:
        return 'none';
    }
  }
}
