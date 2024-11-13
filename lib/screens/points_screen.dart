import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Asegúrate de que esta línea esté presente
import '../services/auth_service.dart';
import 'referral_screen.dart';
import 'transactions_screen.dart'; // Importa la nueva pantalla

class PointsScreen extends StatefulWidget {
  final Map<String, dynamic> translations;

  const PointsScreen({Key? key, required this.translations}) : super(key: key);

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  double _points = 0.0;
  int _firstLevelReferrals = 0;
  int _lowerLevelReferrals = 0;
  bool _isLoading = true;
  bool _hasError = false;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await authService.fetchUserData();
      setState(() {
        _points = data['points'] ?? 0.0;
        _firstLevelReferrals = data['referrals']['level_1'] ?? 0;
        _lowerLevelReferrals = data['lowerLevelReferrals'] ?? 0;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Failed to load user data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _navigateToReferralScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ReferralScreen(translations: widget.translations)),
    );
  }

  void _navigateToTransactionsScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TransactionsScreen(translations: widget.translations),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.translations['transaction']['viewPoints'] ?? 'View Points'),
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
                  onPressed: _fetchUserData,
                ),
              ],
            ),
          )
              : SingleChildScrollView( // Para evitar overflow en pantallas pequeñas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${widget.translations['user']['totalPoints'] ?? 'Total Points'}:',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    '$_points',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${widget.translations['user']['referrals'] ?? 'Referrals'}:',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${widget.translations['user']['firstLevelReferrals'] ?? 'First Level'}:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    '$_firstLevelReferrals',
                    style: const TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${widget.translations['user']['lowerLevelReferrals'] ?? 'Lower Levels'}:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    '$_lowerLevelReferrals',
                    style: const TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                  ),
                ),
                const SizedBox(height: 20), // Espacio adicional
                Center(
                  child: CupertinoButton.filled(
                    onPressed: () => _navigateToTransactionsScreen(context),
                    child: Text(widget.translations['transaction']['viewTransactions'] ?? 'View Transactions'),
                  ),
                ),
                const SizedBox(height: 20), // Espacio entre botones
                Center(
                  child: CupertinoButton.filled(
                    onPressed: () => _navigateToReferralScreen(context),
                    child: Text(widget.translations['user']['viewReferrals'] ?? 'View Referrals'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
