import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/points_screen.dart';  // Asegúrate de importar la pantalla de puntos

class Tab3 extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab3({super.key, required this.translations, required this.onChangeLanguage});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  String _amount = '';

  void _onKeyTapped(String key) {
    setState(() {
      if (key == 'C') {
        _amount = '';
      } else if (key == '←') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        if (_amount.contains('.') && key == '.') return;
        if (_amount.split('.').length == 2 && _amount.split('.')[1].length >= 2) return;
        _amount += key;
      }
    });
  }

  void _initiateNFC() {
    // Lógica para iniciar NFC
    print('Iniciando NFC para $_amount€');
  }

  void _navigateToPointsScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => PointsScreen(translations: widget.translations)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.translations['generateTransaction'] ?? 'Generar Transacción'),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '€$_amount',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: [
                          '1', '2', '3',
                          '4', '5', '6',
                          '7', '8', '9',
                          '.', '0', '←',
                        ].map((key) {
                          return AspectRatio(
                            aspectRatio: 1,
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(4.0),
                              color: CupertinoColors.systemGrey,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(key, style: TextStyle(fontSize: 18)),
                              ),
                              onPressed: () => _onKeyTapped(key),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton.filled(
                      onPressed: _amount.isNotEmpty ? _initiateNFC : null,
                      child: Text(widget.translations['initiateTransaction'] ?? 'Iniciar Transacción'),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton.filled(
                      onPressed: () => _navigateToPointsScreen(context),
                      child: Text(widget.translations['viewPoints'] ?? 'Ver Puntos'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
