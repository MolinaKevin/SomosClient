import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class R {
  R._(this.w, this.h, this.padTop, this.padBottom);

  final double w, h, padTop, padBottom;

  /// baseline = ancho “teléfono” ~ 430 px
  double get _base => 430.0;

  /// Escala principal por ancho: r(16) => 16 * (w/_base)
  double r(double v) => v * (w / _base);

  /// Tamaños de fuente con clamp para no irse en desktop ni en móviles pequeños
  double fs(double v, {double min = 10, double max = 32}) =>
      math.min(math.max(r(v), min), max);

  /// Alturas proporcionales por alto
  double rh(double v) => v * (h / 932.0); // 932 ≈ alto pantalla grande

  /// Alto de la BottomBar + margen de seguridad
  double get bottomBar => 100.0; // BottomAppBar.height
  double get fabClearance => 140.0; // FAB + halo
}
extension ResponsiveX on BuildContext {
  R get r {
    final mq = MediaQuery.of(this);
    return R._(mq.size.width, mq.size.height, mq.padding.top, mq.padding.bottom);
  }
}
