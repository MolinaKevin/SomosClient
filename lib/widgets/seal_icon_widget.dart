import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/seal_service.dart';

class SealIconWidget extends StatefulWidget {
  final Map<String, dynamic> seal;
  final double size;

  const SealIconWidget({
    Key? key,
    required this.seal,
    this.size = 50,
  }) : super(key: key);

  @override
  State<SealIconWidget> createState() => _SealIconWidgetState();
}

class _SealIconWidgetState extends State<SealIconWidget> {
  bool _loading = true;
  bool _error = false;

  String? _src;
  String? _inlineSvgString;

  Uint8List? _memoryBytes;
  bool _isSvg = false;
  bool _isNetwork = false;
  bool _isAsset = false;
  bool _isDataUri = false;

  @override
  void initState() {
    super.initState();
    _resolveSealSource();
  }

  @override
  void didUpdateWidget(covariant SealIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.seal['id'];
    final oldState = (oldWidget.seal['state'] ?? '').toString();
    final newId = widget.seal['id'];
    final newState = (widget.seal['state'] ?? '').toString();

    if (oldId != newId || oldState != newState) {
      // reset y volver a resolver
      _loading = true;
      _error = false;
      _src = null;
      _inlineSvgString = null;
      _memoryBytes = null;
      _isSvg = false;
      _isNetwork = false;
      _isAsset = false;
      _isDataUri = false;
      setState(() {});
      _resolveSealSource();
    }
  }

  bool _looksSvg(String s) =>
      s.toLowerCase().endsWith('.svg') ||
          s.trimLeft().toLowerCase().startsWith('<svg') ||
          s.toLowerCase().startsWith('data:image/svg+xml');

  bool _isDataUrl(String s) => s.startsWith('data:image/');

  Future<void> _resolveSealSource() async {
    try {
      final int id = widget.seal['id'];
      final String state =
      (widget.seal['state'] ?? 'none').toString().toLowerCase();

      final sealService = SealService();
      final seals = await sealService.fetchSeals();

      final meta = seals.firstWhere(
            (s) => s['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (meta.isEmpty) {
        _fail('Seal $id no encontrado');
        return;
      }

      // Preferimos asset_base (mocks) -> icon_svg -> icon -> image
      String? src = (meta['asset_base'] != null && meta['asset_base'].toString().isNotEmpty)
          ? '${meta['asset_base']}/$state.svg'
          : (meta['icon_svg'] ?? meta['icon'] ?? meta['image'])?.toString();

      if (src == null || src.isEmpty) {
        _fail('Seal $id sin icono/imagen');
        return;
      }

      if (src.contains('::STATE::')) {
        src = src.replaceAll('::STATE::', state);
      }

      final isData = _isDataUrl(src);
      final isInlineSvg = src.trimLeft().startsWith('<svg');

      _isSvg = _looksSvg(src);
      _isNetwork = src.startsWith('http://') || src.startsWith('https://');
      _isAsset = !isData && !_isNetwork && !isInlineSvg;
      _isDataUri = isData;

      if (isInlineSvg) {
        _inlineSvgString = src;
      } else if (isData) {
        _handleDataUri(src);
      } else {
        _src = src;
      }

      setState(() {
        _loading = false;
        _error = false;
      });
    } catch (e) {
      _fail('Error resolviendo ícono: $e');
    }
  }

  void _handleDataUri(String dataUri) {
    try {
      final comma = dataUri.indexOf(',');
      if (comma <= 0) {
        _fail('Data URI inválida');
        return;
      }
      final header = dataUri.substring(0, comma);
      final payload = dataUri.substring(comma + 1);

      final isSvg = header.contains('svg+xml');
      final isBase64 = header.contains('base64');

      if (isSvg) {
        _isSvg = true;
        if (isBase64) {
          _memoryBytes = base64.decode(payload);
        } else {
          _inlineSvgString = payload;
        }
      } else {
        if (isBase64) {
          _memoryBytes = base64.decode(payload);
        } else {
          _fail('Data URI raster sin base64 no soportada');
          return;
        }
      }
      _src = dataUri;
    } catch (e) {
      _fail('Error parseando data URI: $e');
    }
  }

  void _fail(String msg) {
    debugPrint(msg);
    setState(() {
      _loading = false;
      _error = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    if (_loading) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.8),
          ),
        ),
      );
    }

    if (_error) {
      return SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.image_not_supported, size: 18),
      );
    }

    if (_inlineSvgString != null) {
      return SvgPicture.string(
        _inlineSvgString!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    if (_memoryBytes != null) {
      if (_isSvg) {
        return SvgPicture.memory(
          _memoryBytes!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      } else {
        return Image.memory(
          _memoryBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }

    if (_src != null) {
      if (_isSvg) {
        if (_isNetwork) {
          return SvgPicture.network(
            _src!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.8),
            ),
          );
        } else if (_isAsset) {
          return SvgPicture.asset(
            _src!,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        }
      } else {
        if (_isNetwork) {
          return Image.network(
            _src!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        } else if (_isAsset) {
          return Image.asset(
            _src!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        }
      }
    }

    return SizedBox(
      width: size,
      height: size,
      child: const Icon(Icons.broken_image, size: 18),
    );
  }
}
