import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../screens/points_screen.dart';

class Tab3 extends StatefulWidget {
  final Map<String, dynamic> translations;
  final Function(Locale) onChangeLanguage;

  const Tab3({Key? key, required this.translations, required this.onChangeLanguage}) : super(key: key);

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  final TextEditingController _amountController = TextEditingController();
  final ValueNotifier<bool> _isAmountValid = ValueNotifier<bool>(false);
  bool _isWaitingForNFC = false;

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
    _checkNFCAvailability();
  }

  bool _validateAmount(String text) {
    if (text.isEmpty || text == '€') {
      return false;
    }
    final amount = text.substring(1);
    return double.tryParse(amount) != null && double.parse(amount) > 0;
  }

  Future<void> _checkNFCAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _showNFCErrorDialog(context);
    }
  }

  void _showWaitingPopup(BuildContext context) {
    setState(() {
      _isWaitingForNFC = true;
    });

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(widget.translations['transaction']?['waitingForDevice'] ?? 'Waiting for device'),
          content: const CupertinoActivityIndicator(),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.translations['common']?['cancel'] ?? 'Cancel'),
              onPressed: () {
                _cancelTransaction();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiateNFC() async {
    try {
      _showWaitingPopup(context);

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        print('NFC Tag discovered: ${tag.data}');
        Navigator.of(context).pop();
        setState(() {
          _isWaitingForNFC = false;
        });
        NfcManager.instance.stopSession();
      });
    } catch (e) {
      print('Error initiating NFC: $e');
      _showNFCErrorDialog(context);
    }
  }

  void _showNFCErrorDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(widget.translations['nfc']?['nfcDisabled'] ?? 'NFC disabled'),
          content: Text(widget.translations['nfc']?['enableNFC'] ?? 'Please enable NFC to continue.'),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.translations['common']?['ok'] ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelTransaction() {
    print('NFC transaction cancelled');
    setState(() {
      _isWaitingForNFC = false;
    });
    NfcManager.instance.stopSession();
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
            middle: Text(widget.translations['transaction']?['generate'] ?? 'Generate Transaction'),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      placeholder: '€0.00',
                      placeholderStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.inactiveGray),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isAmountValid,
                      builder: (context, isValid, child) {
                        return CupertinoButton.filled(
                          onPressed: isValid ? _initiateNFC : null,
                          child: Text(widget.translations['transaction']?['initiateTransaction'] ?? 'Initiate Transaction'),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton.filled(
                      onPressed: () => _navigateToPointsScreen(context),
                      child: Text(widget.translations['user']?['viewPoints'] ?? 'View Points'),
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
