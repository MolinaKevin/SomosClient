import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'referral_screen.dart';
import 'transactions_screen.dart';

class PointsScreen extends StatefulWidget {
  final Map<String, dynamic> translations;

  const PointsScreen({Key? key, required this.translations}) : super(key: key);

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

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
    final viewPointsTitle = t['transaction']['viewPoints'] ?? 'View Points';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(viewPointsTitle, style: const TextStyle(color: _greenDark, fontWeight: FontWeight.w700)),
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
                onPressed: _fetchUserData,
                bg: _greenSoft,
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(
                child: Column(
                  children: [
                    Text(
                      t['user']?['totalPoints'] ?? 'Total Points',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _greenDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_points',
                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: _greenSoft),
                    ),
                  ],
                ),
              ),
              _sectionCard(
                child: Column(
                  children: [
                    Text(
                      t['user']['referrals'] ?? 'Referrals',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _greenDark),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              t['user']['firstLevelReferrals'] ?? 'First Level',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '$_firstLevelReferrals',
                              style: const TextStyle(fontSize: 26, color: _greenSoft, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              t['user']['lowerLevelReferrals'] ?? 'Lower Levels',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '$_lowerLevelReferrals',
                              style: const TextStyle(fontSize: 26, color: _greenSoft, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _pillButton(
                label: t['transaction']['viewTransactions'] ?? 'View Transactions',
                icon: CupertinoIcons.list_bullet,
                onPressed: () => _navigateToTransactionsScreen(context),
              ),
              const SizedBox(height: 12),
              _pillButton(
                label: t['user']['viewReferrals'] ?? 'View Referrals',
                icon: CupertinoIcons.person_2_fill,
                onPressed: () => _navigateToReferralScreen(context),
                bg: _greenSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
