import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../services/seal_service.dart';
import '../config/environment_config.dart';

class SealIconWidget extends StatefulWidget {
  final Map<String, dynamic> seal;

  const SealIconWidget({Key? key, required this.seal}) : super(key: key);

  @override
  _SealIconWidgetState createState() => _SealIconWidgetState();
}

class _SealIconWidgetState extends State<SealIconWidget> {
  Uint8List? _data;
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

      print('Fetching seal for ID: $id and state: $state');

      final sealService = SealService();
      final seals = await sealService.fetchSeals();

      final seal = seals.firstWhere(
            (seal) => seal['id'] == id,
        orElse: () => {},
      );

      if (seal.isEmpty || seal['image'] == null) {
        print('Seal not found or missing image: $id');
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }

      final baseUrl = "http://localhost/storage/";
      final imagePath = seal['image'].replaceAll('::STATE::', widget.seal['state'].toLowerCase());

      final imageUrl = '$baseUrl/$imagePath';
      print('Fetching image for seal: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _data = response.bodyBytes;
          _loading = false;
          _error = false;
        });
      } else {
        print('Failed to load seal image: $imageUrl');
        setState(() {
          _loading = false;
          _error = true;
        });
      }
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
    } else if (_error || _data == null) {
      return const Icon(Icons.image_not_supported, size: 50);
    } else {
      return SvgPicture.memory(
        _data!,
        width: 50,
        height: 50,
      );
    }
  }
}
