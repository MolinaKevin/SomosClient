import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SealSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sealsWithState;
  final Function(List<Map<String, dynamic>> updatedSeals) onSealStateChanged;

  SealSelectionWidget({
    required this.sealsWithState,
    required this.onSealStateChanged,
  });

  @override
  _SealSelectionWidgetState createState() => _SealSelectionWidgetState();
}

class _SealSelectionWidgetState extends State<SealSelectionWidget> {
  late List<Map<String, dynamic>> _seals;
  final List<String> states = ['none', 'partial', 'full'];
  final List<String> stateLabels = ['Nada', 'Algo', 'Todo'];

  @override
  void initState() {
    super.initState();
    _seals = widget.sealsWithState.map((seal) {
      if (!states.contains(seal['state'])) {
        seal['state'] = 'none';
      }
      return Map<String, dynamic>.from(seal);
    }).toList();
  }

  void _updateSealState(int index, String newState) {
    setState(() {
      _seals[index]['state'] = newState;
    });
    widget.onSealStateChanged(_seals);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 150),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stateLabels
                      .map((label) => Text(label, style: TextStyle(fontSize: 12)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _seals.length,
            itemBuilder: (context, index) {
              return SealItemWidget(
                seal: _seals[index],
                states: states,
                onStateChanged: (newState) {
                  _updateSealState(index, newState);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SealItemWidget extends StatefulWidget {
  final Map<String, dynamic> seal;
  final List<String> states;
  final Function(String newState) onStateChanged;

  SealItemWidget({
    required this.seal,
    required this.states,
    required this.onStateChanged,
  });

  @override
  _SealItemWidgetState createState() => _SealItemWidgetState();
}

class _SealItemWidgetState extends State<SealItemWidget> {
  String? assetPath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SealItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImage();
  }

  void _loadImage() {
    final seal = widget.seal;
    final state = seal['state'] ?? 'none';
    String? imagePath = seal['image'] as String?;

    if (imagePath == null || imagePath.isEmpty) {
      setState(() {
        assetPath = null;
      });
      return;
    }

    imagePath = imagePath.replaceAll('::STATE::', state);
    setState(() {
      assetPath = '$imagePath';
    });
  }

  @override
  Widget build(BuildContext context) {
    final seal = widget.seal;
    final state = seal['state'] ?? 'none';
    int currentIndex = widget.states.indexOf(state);
    if (currentIndex == -1) {
      currentIndex = 0;
    }

    Widget leading;
    if (assetPath == null) {
      leading = Icon(Icons.image_not_supported, size: 40);
    } else {
      leading = SvgPicture.asset(
        assetPath!,
        width: 40,
        height: 40,
      );
    }

    return Column(
      children: [
        ListTile(
          leading: leading,
          title: Container(),
          trailing: SizedBox(
            width: 300,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
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
        const Divider(),
      ],
    );
  }
}
