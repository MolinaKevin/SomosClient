import 'package:flutter/material.dart';
import '../widgets/seal_icon_widget.dart';

class SealSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sealsWithState;

  /// Se dispara en cada cambio
  final ValueChanged<List<Map<String, dynamic>>>? onSealStateChanged;

  /// Se dispara al tocar “Aplicar”.
  final ValueChanged<List<Map<String, dynamic>>>? onApply;

  /// Se dispara al tocar “Limpiar”.
  final VoidCallback? onClearAll;

  const SealSelectionWidget({
    Key? key,
    required this.sealsWithState,
    this.onSealStateChanged,
    this.onApply,
    this.onClearAll,
  }) : super(key: key);

  @override
  _SealSelectionWidgetState createState() => _SealSelectionWidgetState();
}

class _SealSelectionWidgetState extends State<SealSelectionWidget> {
  late List<Map<String, dynamic>> _seals;
  final List<String> states = const ['none', 'partial', 'full'];
  final List<String> stateLabels = const ['Nada', 'Algo', 'Todo'];

  @override
  void initState() {
    super.initState();
    _seals = widget.sealsWithState.map((seal) {
      final s = Map<String, dynamic>.from(seal);
      final raw = (s['state'] ?? 'none').toString().toLowerCase();
      s['state'] = _normalize(raw);
      return s;
    }).toList();
  }

  String _normalize(String v) {
    switch (v) {
      case 'verified':
        return 'full';
      case 'candidate':
        return 'partial';
      case 'full':
      case 'partial':
        return v;
      default:
        return 'none';
    }
  }

  void _updateSealState(int index, String newState) {
    setState(() {
      _seals[index]['state'] = newState;
    });
    widget.onSealStateChanged?.call(_seals);
  }

  void _apply() {
    widget.onApply?.call(_seals);
  }

  void _clearAll() {
    for (final s in _seals) {
      s['state'] = 'none';
    }
    setState(() {});
    widget.onSealStateChanged?.call(_seals);
    widget.onClearAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // encabezado de columnas (labels del slider)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 150),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stateLabels
                      .map((label) =>
                      Text(label, style: const TextStyle(fontSize: 12)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // lista de sellos
        Expanded(
          child: ListView.builder(
            itemCount: _seals.length,
            itemBuilder: (context, index) {
              return SealItemWidget(
                seal: _seals[index],
                states: states,
                onStateChanged: (newState) => _updateSealState(index, newState),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // acciones
        Row(
          children: [
            OutlinedButton(
              onPressed: _clearAll,
              child: const Text('Limpiar'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _apply,
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ],
    );
  }
}

class SealItemWidget extends StatefulWidget {
  final Map<String, dynamic> seal;
  final List<String> states;
  final ValueChanged<String> onStateChanged;

  const SealItemWidget({
    Key? key,
    required this.seal,
    required this.states,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  _SealItemWidgetState createState() => _SealItemWidgetState();
}

class _SealItemWidgetState extends State<SealItemWidget> {
  @override
  Widget build(BuildContext context) {
    final seal = widget.seal;
    final String state = (seal['state'] ?? 'none').toString();
    int currentIndex = widget.states.indexOf(state);
    if (currentIndex == -1) currentIndex = 0;

    final leading = SealIconWidget(
      key: ValueKey('seal-${seal['id']}-$state'),
      seal: {'id': seal['id'], 'state': state},
      size: 40,
    );

    return Column(
      children: [
        ListTile(
          leading: leading,
          title: Text(
            (seal['name'] ?? '').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: SizedBox(
            width: 300,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10.0,
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 10.0),
              ),
              child: Slider(
                value: currentIndex.toDouble(),
                min: 0,
                max: (widget.states.length - 1).toDouble(),
                divisions: widget.states.length - 1,
                onChanged: (value) {
                  final newState = widget.states[value.toInt()];
                  widget.onStateChanged(newState);
                },
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
