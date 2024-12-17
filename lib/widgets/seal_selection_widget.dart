import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

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
  static final Map<String, Uint8List> _imageCache = {};
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _error = false;

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

  Future<void> _loadImage() async {
    final baseUrl = 'http://localhost/storage/';
    final seal = widget.seal;
    final state = seal['state'] ?? 'none';
    String? imagePath = seal['image'] as String?;
    if (imagePath == null || imagePath.isEmpty) {
      setState(() {
        _imageData = null;
        _error = false;
        _isLoading = false;
      });
      return;
    }

    imagePath = imagePath.replaceAll('::STATE::', state);
    final imageUrl = '$baseUrl$imagePath';

    if (_imageCache.containsKey(imageUrl)) {
      setState(() {
        _imageData = _imageCache[imageUrl]!;
        _error = false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = false;
      });
      try {
        final data = await _fetchSvg(imageUrl);
        _imageCache[imageUrl] = data;
        setState(() {
          _imageData = data;
          _isLoading = false;
          _error = false;
        });
      } catch (e) {
        setState(() {
          _error = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List> _fetchSvg(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load SVG');
    }
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
    if (_isLoading) {
      leading = Icon(Icons.hourglass_empty);
    } else if (_error || _imageData == null) {
      leading = Icon(Icons.image_not_supported, size: 40);
    } else {
      leading = SvgPicture.memory(
        _imageData!,
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
