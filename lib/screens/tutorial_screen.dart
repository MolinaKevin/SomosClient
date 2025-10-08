import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;

class TutorialPageData {
  final String title;
  final String description;
  final String imagePath;

  const TutorialPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  static const cream = Color(0xFFFFF5E6);
  static const greenLight = Color(0xFF47894A);
  static const greenDark = Color(0xFF103322);

  final _controller = PageController();
  int _index = 0;

  final List<TutorialPageData> _pages = const [
    TutorialPageData(
      title: '¿Qué es SOMOS?',
      description:
      'Una plataforma que fortalece la economía local conectando comercios, organizaciones y personas. Cada compra suma puntos y financia proyectos cercanos.',
      imagePath: 'assets/images/tutorial/tutorial1.png',
    ),
    TutorialPageData(
      title: 'Cómo funciona',
      description:
      'Pagás en un comercio adherido → ganás puntos.\nEntidades sin fines de lucro reciben donaciones de parte de SOMOS en base a los puntos generados.',
      imagePath: 'assets/images/tutorial/tutorial2.png',
    ),
    TutorialPageData(
      title: 'Para personas',
      description:
      'Descubrí lugares cerca tuyo, ahorrá con beneficios y apoyá causas locales sin pagar extra. Todo desde una sola app.',
      imagePath: 'assets/images/tutorial/tutorial3.png',
    ),
    TutorialPageData(
      title: 'Para comercios',
      description:
      'Más visibilidad en el mapa y en la lista, una comunidad activa y una solución de marketing de bajo costo.',
      imagePath: 'assets/images/tutorial/tutorial1.png',
    ),
    TutorialPageData(
      title: 'Para organizaciones',
      description:
      'Ingresos recurrentes y un canal directo con la comunidad para impulsar proyectos con impacto real en el territorio.',
      imagePath: 'assets/images/tutorial/tutorial2.png',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _prev() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildImage(String path, double height) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        height: height,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      );
    }
    return Image.asset(path, height: height, fit: BoxFit.contain);
  }

  double _clamp(double v, double min, double max) =>
      v.clamp(min, max).toDouble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                  },
                ),
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];

                    return LayoutBuilder(builder: (context, c) {
                      final w = c.maxWidth;
                      final h = c.maxHeight;

                      final titleSize = _clamp(w * 0.095, 24, 40);
                      final descSize = _clamp(w * 0.078, 20, 34);
                      final imgHeight =
                      _clamp(h * 0.45, 240, math.max(300, h * 0.52));

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _clamp(w * 0.06, 20, 28),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              p.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: titleSize,
                                height: 1.1,
                                color: greenLight,
                              ),
                            ),
                            SizedBox(height: _clamp(h * 0.02, 10, 24)),
                            _buildImage(p.imagePath, imgHeight),
                            SizedBox(height: _clamp(h * 0.03, 14, 28)),
                            Text(
                              p.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: descSize,
                                height: 1.28,
                                color: greenDark.withOpacity(0.92),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  height: 10,
                  width: active ? 26 : 10,
                  decoration: BoxDecoration(
                    color: active ? greenDark : greenDark.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_index > 0)
                        OutlinedButton.icon(
                          onPressed: _prev,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Anterior'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: greenDark,
                            side: BorderSide(color: greenDark.withOpacity(0.8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      if (_index > 0) const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Saltar'),
                      ),
                    ],
                  ),

                  ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                        _index == _pages.length - 1 ? 'Empezar' : 'Siguiente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
