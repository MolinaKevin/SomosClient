import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../screens/points_screen.dart';
import '../services/transaction_service.dart';

class TabPay extends StatefulWidget {
  final Map<String, dynamic> translations;
  final Function(Locale) onChangeLanguage;

  const TabPay({
    Key? key,
    required this.translations,
    required this.onChangeLanguage,
  }) : super(key: key);

  @override
  _TabPayState createState() => _TabPayState();
}

class _TabPayState extends State<TabPay> {
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

  final TextEditingController _amountController = TextEditingController(text: '€');
  final ValueNotifier<bool> _isAmountValid = ValueNotifier<bool>(false);
  final TransactionService _tx = TransactionService();

  bool _waitingShown = false;
  bool _handledTag = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _checkNFCAvailability();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  Widget _sectionCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _pillButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Color bg = _greenDark,
    Color fg = Colors.white,
    EdgeInsets? padding,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: onPressed == null ? .6 : 1,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _onAmountChanged() {
    final raw = _amountController.text;
    if (!raw.startsWith('€')) {
      final only = raw.replaceAll('€', '');
      _amountController.value = _amountController.value.copyWith(
        text: '€$only',
        selection: TextSelection.collapsed(offset: ('€$only').length),
        composing: TextRange.empty,
      );
    }
    _isAmountValid.value = _validateAmount(_amountController.text);
  }

  bool _validateAmount(String text) {
    if (text.isEmpty || text == '€') return false;
    final numPart = text.substring(1).trim().replaceAll(',', '.');
    final parsed = double.tryParse(numPart);
    return parsed != null && parsed > 0;
  }

  double _currentAmountOrZero() {
    final t = _amountController.text;
    if (!_validateAmount(t)) return 0;
    final normalized = t.substring(1).trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  void _applyPreset(double value) {
    final txt = '€${value.toStringAsFixed(2)}';
    _amountController.value = TextEditingValue(
      text: txt,
      selection: TextSelection.collapsed(offset: txt.length),
    );
  }

  Future<void> _checkNFCAvailability() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable && mounted) _showNFCErrorDialog();
  }

  void _showWaitingPopup() {
    if (!mounted) return;
    _waitingShown = true;
    final rootNav = Navigator.of(context, rootNavigator: true);
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: Text(widget.translations['transaction']['waitingForDevice'] ?? 'Waiting for device'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(height: 8),
              Text('${widget.translations['transaction']['amount'] ?? 'Amount'}: €${_currentAmountOrZero().toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(widget.translations['common']['cancel'] ?? 'Cancel'),
            onPressed: () {
              _cancelSession();
              if (rootNav.canPop()) rootNav.pop();
              _waitingShown = false;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _initiateNFC() async {
    final available = await NfcManager.instance.isAvailable();
    if (!available) {
      _showNFCErrorDialog();
      return;
    }

    _handledTag = false;
    _showWaitingPopup();

    final pollingOptions = Platform.isAndroid
        ? <NfcPollingOption>{NfcPollingOption.iso14443, NfcPollingOption.iso15693, NfcPollingOption.iso18092}
        : <NfcPollingOption>{NfcPollingOption.iso14443, NfcPollingOption.iso15693};

    await NfcManager.instance.startSession(
      pollingOptions: pollingOptions,
      onDiscovered: (NfcTag tag) async {
        if (_handledTag) return;
        _handledTag = true;
        try {
          final amount = _currentAmountOrZero();
          await _tx.createMockTransaction(amount: amount);
        } finally {
          await NfcManager.instance.stopSession();
        }

        if (!mounted) return;

        final rootNav = Navigator.of(context, rootNavigator: true);
        if (_waitingShown && rootNav.canPop()) {
          rootNav.pop();
          _waitingShown = false;
        }

        Future.microtask(() {
          if (!mounted) return;
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: Text(widget.translations['common']?['success'] ?? 'Success'),
              content: Text(
                (widget.translations['transaction']?['done'] ?? 'Transaction completed.') +
                    '  €${_currentAmountOrZero().toStringAsFixed(2)}',
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(widget.translations['common']?['ok'] ?? 'OK'),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showNFCErrorDialog() {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(widget.translations['nfc']['nfcDisabled'] ?? 'NFC disabled'),
        content: Text(widget.translations['nfc']['enableNFC'] ?? 'Please enable NFC to continue.'),
        actions: [
          CupertinoDialogAction(
            child: Text(widget.translations['common']['ok'] ?? 'OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
    );
  }

  void _cancelSession() {
    NfcManager.instance.stopSession();
  }

  void _navigateToPointsScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => PointsScreen(translations: widget.translations)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translations;
    final title = t['transaction']?['generate'] ?? 'Generate Transaction';
    final placeholder = '€0.00';
    final payNow = t['transaction']?['initiateTransaction'] ?? 'Initiate Transaction';
    final viewPoints = t['user']?['viewPoints'] ?? 'View Points';

    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(title, style: const TextStyle(color: _greenDark, fontWeight: FontWeight.w700)),
            backgroundColor: _cream.withOpacity(.96),
            border: const Border(bottom: BorderSide(color: Colors.transparent)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionCard(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: _greenDark,
                            height: 1.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _greenSoft.withOpacity(.18), width: 1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          placeholder: placeholder,
                          placeholderStyle: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.black26,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final v in const [5, 10, 20, 50, 100])
                              _pillButton(
                                label: '€${v.toStringAsFixed(0)}',
                                onPressed: () => _applyPreset(v.toDouble()),
                                bg: Colors.white,
                                fg: _greenDark,
                                icon: CupertinoIcons.add_circled_solid,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isAmountValid,
                    builder: (context, isValid, _) {
                      return _pillButton(
                        label: payNow,
                        icon: CupertinoIcons.waveform_path_ecg,
                        onPressed: isValid ? _initiateNFC : null,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _pillButton(
                    label: viewPoints,
                    icon: CupertinoIcons.star_circle_fill,
                    onPressed: _navigateToPointsScreen,
                    bg: _greenSoft,
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.info_circle_fill, color: _greenSoft),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t['transaction']?['hint'] ??
                                'Bring the card or device close to your phone to read NFC and complete the transaction.',
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.25),
                          ),
                        ),
                      ],
                    ),
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
