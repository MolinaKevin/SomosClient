import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'referral_screen.dart';

class PointsScreen extends StatelessWidget {
  final Map<String, String> translations;

  const PointsScreen({super.key, required this.translations});

  void _navigateToReferralScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ReferralScreen(translations: translations)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translations['viewPoints'] ?? 'Ver Puntos'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${translations['totalPoints'] ?? 'Total de Puntos'}:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '25555', // Esta cantidad debería ser dinámica
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${translations['referrals'] ?? 'Referidos'}:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${translations['firstLevelReferrals'] ?? 'Primer Nivel'}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '10', // Esta cantidad debería ser dinámica
                  style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${translations['lowerLevelReferrals'] ?? 'Niveles Inferiores'}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '25', // Esta cantidad debería ser dinámica
                  style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: CupertinoButton.filled(
                  onPressed: () => _navigateToReferralScreen(context),
                  child: Text(translations['viewReferrals'] ?? 'Ver'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
