import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../map_widget.dart';

class Tab1 extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;
  final Map<String, dynamic> translations;
  final VoidCallback onTapList;
  final GlobalKey? viewSwitchKey;
  final GlobalKey? controlsKey;
  final GlobalKey? mapAreaKey;

  const Tab1({
    Key? key,
    required this.scaffoldKey,
    required this.isAuthenticated,
    required this.translations,
    required this.onTapList,
    this.viewSwitchKey,
    this.controlsKey,
    this.mapAreaKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyMapWidget(
      scaffoldKey: scaffoldKey,
      isAuthenticated: isAuthenticated,
      translations: translations,
      onTapList: onTapList,
      viewSwitchKey: viewSwitchKey,
      controlsKey: controlsKey,
      mapAreaKey: mapAreaKey,
    );
  }
}
