import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/referral_screen.dart';
import '../screens/transaction_screen.dart';

class Tab3 extends StatelessWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab3({super.key, required this.translations, required this.onChangeLanguage});

  void _navigateToReferralScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ReferralScreen(translations: translations)),
    );
  }

  void _navigateToTransactionScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TransactionScreen(translations: translations)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '${translations['totalPoints'] ?? 'Total de Puntos'}:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '25555', // Esta cantidad debería ser dinámica
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${translations['referral'] ?? 'Referidos'}:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${translations['firstLevelReferrals'] ?? 'Primer Nivel'}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '10', // Esta cantidad debería ser dinámica
                            style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${translations['lowerLevelReferrals'] ?? 'Niveles Inferiores'}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '25', // Esta cantidad debería ser dinámica
                            style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          CupertinoButton.filled(
                            onPressed: () => _navigateToReferralScreen(context),
                            child: Text(translations['viewReferrals'] ?? 'Ver'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  CupertinoButton.filled(
                    onPressed: () => _navigateToTransactionScreen(context),
                    child: Text(translations['generateTransaction'] ?? 'Generar Transacción'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
