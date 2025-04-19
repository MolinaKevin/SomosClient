import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../mocking/mock_seal_service.dart';

class SealIconWidget extends StatefulWidget {
  final Map<String, dynamic> seal;

  const SealIconWidget({Key? key, required this.seal}) : super(key: key);

  @override
  _SealIconWidgetState createState() => _SealIconWidgetState();
}

class _SealIconWidgetState extends State<SealIconWidget> {
  String? _assetPath;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchSealImage();
  }

  Future<void> _fetchSealImage() async {
    try {
      final int id = widget.seal['id'];
      final String state = widget.seal['state'] ?? 'none';

      final sealService = MockSealService();
      final seals = await sealService.fetchSeals();

      final seal = seals.firstWhere(
            (seal) => seal['id'] == id,
        orElse: () => {},
      );

      if (seal.isEmpty || seal['image'] == null) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }

      final imagePath = seal['image'].replaceAll('::STATE::', state.toLowerCase());

      setState(() {
        _assetPath = imagePath;
        _loading = false;
        _error = false;
      });
    } catch (e) {
      print('Error fetching seal data: $e');
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Icon(Icons.hourglass_empty, size: 50);
    } else if (_error || _assetPath == null) {
      return const Icon(Icons.image_not_supported, size: 50);
    } else {
      return SvgPicture.asset(
        _assetPath!,
        width: 50,
        height: 50,
      );
    }
  }
}
