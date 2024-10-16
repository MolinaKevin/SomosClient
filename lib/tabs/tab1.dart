import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../map_widget.dart';

class Tab1 extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;
  final Map<String, String> translations; // Agregar el parámetro translations

  const Tab1({
    super.key,
    required this.scaffoldKey,
    required this.isAuthenticated,
    required this.translations, // Añadir translations como requerido
  });

  @override
  Widget build(BuildContext context) {
    return MyMapWidget(
      scaffoldKey: scaffoldKey,
      isAuthenticated: isAuthenticated,
      translations: translations, // Pasar translations a MyMapWidget
    );
  }
}
