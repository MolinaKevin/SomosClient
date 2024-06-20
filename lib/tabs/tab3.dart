import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/points_screen.dart'; // Asegúrate de importar la pantalla de puntos

class Tab3 extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab3({super.key, required this.translations, required this.onChangeLanguage});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  final TextEditingController _amountController = TextEditingController();
  final ValueNotifier<bool> _isAmountValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text;
      if (!text.startsWith('€')) {
        _amountController.value = _amountController.value.copyWith(
          text: '€' + text.replaceAll('€', ''),
          selection: TextSelection.fromPosition(
            TextPosition(offset: _amountController.text.length),
          ),
        );
      }
      _isAmountValid.value = _validateAmount(_amountController.text);
    });
  }

  bool _validateAmount(String text) {
    if (text.isEmpty || text == '€') {
      return false;
    }
    final amount = text.substring(1); // Remove €
    return double.tryParse(amount) != null && double.parse(amount) > 0;
  }

  void _initiateNFC() {
    // Lógica para iniciar NFC
    print('Iniciando NFC para ${_amountController.text}');
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
                    CupertinoTextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      placeholder: '€0.00',
                      placeholderStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.inactiveGray),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isAmountValid,
                      builder: (context, isValid, child) {
                        return CupertinoButton.filled(
                          onPressed: isValid ? _initiateNFC : null,
                          child: Text(widget.translations['initiateTransaction'] ?? 'Iniciar Transacción'),
                        );
                      },
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
