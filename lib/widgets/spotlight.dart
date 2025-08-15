import 'dart:async';
import 'package:flutter/material.dart';

enum SpotlightPlacement { auto, above, below, left, right }

class Spotlight {
  Spotlight(this.context);
  final BuildContext context;
  OverlayEntry? _entry;

  Future<void> showForKey(
      GlobalKey key, {
        required String label,
        bool circular = false,
        double extraPadding = 8,
        SpotlightPlacement placement = SpotlightPlacement.auto,
        Offset labelOffset = Offset.zero,
        double bubbleWidth = 280,
        VoidCallback? onTapInside,
      }) async {
    // Espera un frame para asegurar layout
    await WidgetsBinding.instance.endOfFrame;

    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final offset = box.localToGlobal(Offset.zero);
    final rect   = (offset & box.size).inflate(extraPadding);

    final completer = Completer<void>();
    _entry = OverlayEntry(
      builder: (_) => SpotlightOverlay(
        holeRect: rect,
        borderRadius: circular ? 999 : 16,
        label: label,
        placement: placement,
        labelOffset: labelOffset,
        bubbleWidth: bubbleWidth,
        onTapInside: () {
          dismiss();
          onTapInside?.call();
          if (!completer.isCompleted) completer.complete();
        },
        onTapOutside: () {
          dismiss();
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    return completer.future;
  }

  void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class SpotlightOverlay extends StatelessWidget {
  final Rect holeRect;
  final double borderRadius;
  final VoidCallback onTapInside;
  final VoidCallback? onTapOutside;
  final String? label;

  final SpotlightPlacement placement;
  final Offset labelOffset;
  final double bubbleWidth;

  const SpotlightOverlay({
    super.key,
    required this.holeRect,
    required this.onTapInside,
    this.onTapOutside,
    this.borderRadius = 16,
    this.label,
    this.placement = SpotlightPlacement.auto,
    this.labelOffset = Offset.zero,
    this.bubbleWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          if (holeRect.contains(d.globalPosition)) {
            onTapInside();
          } else {
            onTapOutside?.call();
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: _HolePainter(holeRect, borderRadius),
              child: const SizedBox.expand(),
            ),
            if (label != null) _positionedBubble(context),
          ],
        ),
      ),
    );
  }

  Widget _positionedBubble(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const margin = 12.0;
    final double w =
    (bubbleWidth.clamp(160.0, size.width - 2 * margin)).toDouble();

    SpotlightPlacement p = placement;
    if (p == SpotlightPlacement.auto) {
      p = (holeRect.top > size.height * 0.33)
          ? SpotlightPlacement.above
          : SpotlightPlacement.below;
    }

    double clampLeft(double left) =>
        left.clamp(margin, size.width - w - margin);

    switch (p) {
      case SpotlightPlacement.above:
        final bottom = (size.height - holeRect.top) + margin - labelOffset.dy;
        final left = clampLeft(holeRect.center.dx - w / 2 + labelOffset.dx);
        return Positioned(left: left, bottom: bottom, width: w, child: _Bubble(label: label!));

      case SpotlightPlacement.below:
        final top = holeRect.bottom + margin + labelOffset.dy;
        final left = clampLeft(holeRect.center.dx - w / 2 + labelOffset.dx);
        return Positioned(left: left, top: top, width: w, child: _Bubble(label: label!));

      case SpotlightPlacement.left:
        final right = (size.width - holeRect.left) + margin - labelOffset.dx;
        final top = (holeRect.center.dy - 50 + labelOffset.dy)
            .clamp(margin, size.height - 100 - margin);
        return Positioned(right: right, top: top, width: w, child: _Bubble(label: label!));

      case SpotlightPlacement.right:
        final left = holeRect.right + margin + labelOffset.dx;
        final top = (holeRect.center.dy - 50 + labelOffset.dy)
            .clamp(margin, size.height - 100 - margin);
        return Positioned(left: left, top: top, width: w, child: _Bubble(label: label!));

      case SpotlightPlacement.auto:
        final top = holeRect.bottom + margin + labelOffset.dy;
        final left = clampLeft(holeRect.center.dx - w / 2 + labelOffset.dx);
        return Positioned(left: left, top: top, width: w, child: _Bubble(label: label!));
    }
  }
}

class _HolePainter extends CustomPainter {
  final Rect rect;
  final double radius;
  _HolePainter(this.rect, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);
    final bg = Path()..addRect(Offset.zero & size);
    final hole = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()
      ..addPath(bg, Offset.zero)
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(hole, outline);
  }

  @override
  bool shouldRepaint(covariant _HolePainter old) =>
      rect != old.rect || radius != old.radius;
}

class _Bubble extends StatelessWidget {
  final String label;
  const _Bubble({required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
