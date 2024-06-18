import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../map_widget.dart';

class Tab1 extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Tab1({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return MyMapWidget(scaffoldKey: scaffoldKey);
  }
}
