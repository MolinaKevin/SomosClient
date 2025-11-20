import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final Map<String, dynamic> translations;

  const TransactionsScreen({Key? key, required this.translations}) : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _transactions = [];
  final TransactionService transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await transactionService.fetchAllTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
        _hasError = false;
      });
    } on MissingPluginException catch (_) {
      setState(() {
        _transactions = [];
        _isLoading = false;
        _hasError = true;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _retryFetching() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _fetchTransactions();
  }

  IconData _getTransactionIcon(String type) {
    if (type == 'purchase') return CupertinoIcons.money_dollar_circle_fill;
    if (type == 'pointPurchase') return CupertinoIcons.star_circle_fill;
    if (type == 'referralPoint') return CupertinoIcons.person_2_fill;
    return CupertinoIcons.question_circle_fill;
  }

  Color _getTransactionColor(String type) {
    if (type == 'purchase') return _greenDark;
    if (type == 'pointPurchase') return _greenSoft;
    if (type == 'referralPoint') return CupertinoColors.systemBlue;
    return Colors.black54;
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return date;
    return DateFormat.yMMMd().add_Hm().format(parsedDate);
  }

  Widget _pillButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color bg = _greenDark,
    Color fg = Colors.white,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }

  Widget _sectionCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translations;
    final title = t['transaction']['viewTransactions'] ?? 'View Transactions';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title, style: const TextStyle(color: _greenDark, fontWeight: FontWeight.w700)),
        backgroundColor: _cream.withOpacity(.96),
        border: const Border(bottom: BorderSide(color: Colors.transparent)),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _hasError
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t['common']['failedToLoadData'] ?? 'Failed to load data',
                style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _pillButton(
                label: t['common']['retry'] ?? 'Retry',
                icon: CupertinoIcons.refresh,
                onPressed: _retryFetching,
                bg: _greenSoft,
              ),
            ],
          ),
        )
            : _transactions.isEmpty
            ? Center(
          child: Text(
            t['transaction']['noTransactions'] ?? 'No transactions found.',
            style: const TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _transactions.length,
          itemBuilder: (BuildContext context, int index) {
            final transaction = _transactions[index];
            final type = transaction['type'] ?? 'unknown';
            final commerce = transaction['commerce'];
            final commerceName = commerce != null && commerce.containsKey('name')
                ? commerce['name']
                : 'Unknown Commerce';
            final amount = (transaction['money'] is String
                ? double.tryParse(transaction['money'])
                : transaction['money']?.toDouble()) ??
                0.0;
            final points = (transaction['points'] is String
                ? double.tryParse(transaction['points'])
                : transaction['points']?.toDouble()) ??
                0.0;
            final date = transaction['date'] ?? '';
            final donationPlaceholder =
                t['transaction']['donationFor'] ?? 'Donation for';
            final referralDescription = t['transaction']['referralPurchase'] ??
                'Compra realizada por un referido';

            return _sectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _getTransactionColor(type).withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(_getTransactionIcon(type),
                        color: _getTransactionColor(type), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type == 'referralPoint'
                              ? referralDescription
                              : '${t['transaction']['purchaseAt'] ?? 'Purchase at'} $commerceName',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        if (type == 'purchase')
                          Text(
                            '$donationPlaceholder: Placeholder Name',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54, height: 1.2),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black45, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${points.toStringAsFixed(2)} pts',
                        style: TextStyle(
                          color: _getTransactionColor(type),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (type == 'purchase')
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: _greenSoft,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
