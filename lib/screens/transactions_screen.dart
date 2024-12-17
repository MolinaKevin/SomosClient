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
      print('Transaction data received: $_transactions');
    } on MissingPluginException catch (e) {
      print('Transaction plugin not available: $e');
      setState(() {
        _transactions = [];
        _isLoading = false;
        _hasError = true;
      });
    } catch (e) {
      print('Error al cargar transacciones: $e');
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
    if (type == 'purchase') {
      return CupertinoIcons.money_dollar;
    } else if (type == 'pointPurchase') {
      return CupertinoIcons.star;
    } else if (type == 'referralPoint') {
      return CupertinoIcons.person_add;
    } else {
      return CupertinoIcons.question_circle;
    }
  }

  Color _getTransactionColor(String type) {
    if (type == 'purchase') {
      return CupertinoColors.activeGreen;
    } else if (type == 'pointPurchase') {
      return CupertinoColors.destructiveRed;
    } else if (type == 'referralPoint') {
      return CupertinoColors.systemBlue;
    } else {
      return CupertinoColors.black;
    }
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat.yMMMd().add_Hm().format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.translations['transaction']['viewTransactions'] ?? 'View Transactions'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.translations['common']['failedToLoadData'] ?? 'Failed to load data',
                  style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 18),
                ),
                CupertinoButton(
                  child: Text(widget.translations['common']['retry'] ?? 'Retry'),
                  onPressed: _retryFetching,
                ),
              ],
            ),
          )
              : _transactions.isEmpty
              ? Center(
            child: Text(
              widget.translations['transaction']['noTransactions'] ?? 'No transactions found.',
              style: const TextStyle(fontSize: 18),
            ),
          )
              : ListView.builder(
            itemCount: _transactions.length,
            itemBuilder: (BuildContext context, int index) {
              final transaction = _transactions[index];
              final type = transaction['type'] ?? 'unknown';

              final commerce = transaction['commerce'];
              final commerceName = commerce != null && commerce.containsKey('name')
                  ? commerce['name']
                  : 'Unknown Commerce';
              final amount = (transaction['money'] is String
                  ? double.tryParse(transaction['money']) ?? 0.0
                  : transaction['money']?.toDouble()) ?? 0.0;
              final points = (transaction['points'] is String
                  ? double.tryParse(transaction['points']) ?? 0.0
                  : transaction['points']?.toDouble()) ?? 0.0;
              final date = transaction['date'] ?? 'No Date';

              final donationPlaceholder = widget.translations['transaction']['donationFor'] ?? 'Donation for';
              final donationNames = 'Placeholder Name';
              final referralDescription = widget.translations['transaction']['referralPurchase'] ??
                  'Compra realizada por un referido';

              return Card(
                child: ListTile(
                  leading: Icon(
                    _getTransactionIcon(type),
                    color: _getTransactionColor(type),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == 'referralPoint'
                            ? referralDescription
                            : '${widget.translations['transaction']['purchaseAt'] ?? 'Purchase at'} $commerceName',
                      ),
                      const SizedBox(height: 4),
                      if (type == 'purchase')
                        Text(
                          '$donationPlaceholder: $donationNames',
                          style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                        ),
                    ],
                  ),
                  subtitle: Text(_formatDate(date)),
                  trailing: Column(
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
                          style: TextStyle(
                            color: CupertinoColors.activeGreen,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
