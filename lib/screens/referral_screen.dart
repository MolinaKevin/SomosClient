import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  final Map<String, String> translations;

  const ReferralScreen({super.key, required this.translations});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translations['viewReferrals'] ?? 'Ver Referidos'),
      ),
      child: Center(
        child: Text('Detalles de los referidos aquí'),
      ),
    );
  }
}
