import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ReferralScreen extends StatefulWidget {
  final Map<String, dynamic> translations;

  const ReferralScreen({Key? key, required this.translations}) : super(key: key);

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

  final AuthService _authService = AuthService();
  Map<String, int> _referrals = {
    'level_1': 0,
    'level_2': 0,
    'level_3': 0,
    'level_4': 0,
    'level_5': 0,
    'level_6': 0,
    'level_7': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferralData();
  }

  Future<void> _fetchReferralData() async {
    try {
      final data = await _authService.fetchUserData();
      final referrals = Map<String, dynamic>.from(data['referrals'] ?? {});
      setState(() {
        _referrals = {
          'level_1': (referrals['level_1'] ?? 0) as int,
          'level_2': (referrals['level_2'] ?? 0) as int,
          'level_3': (referrals['level_3'] ?? 0) as int,
          'level_4': (referrals['level_4'] ?? 0) as int,
          'level_5': (referrals['level_5'] ?? 0) as int,
          'level_6': (referrals['level_6'] ?? 0) as int,
          'level_7': (referrals['level_7'] ?? 0) as int,
        };
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _t(String section, String key, String fallback) {
    final sec = widget.translations[section] as Map<String, dynamic>?;
    return (sec?[key] ?? fallback).toString();
  }

  Widget _pill({required String label, IconData? icon, required VoidCallback onPressed}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: _greenDark,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _levelRow(String title, int count) {
    final chips = List.generate(
      count,
          (i) => Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF103D1B)),
        child: Center(
          child: Text(
            '${i + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _greenSoft.withOpacity(.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: _greenSoft, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (count == 0)
            const Text('—', style: TextStyle(color: Colors.black38))
          else
            Wrap(children: chips),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translations;
    final title = t['referrals']?['view'] ?? 'View Referrals';
    final heading = t['referrals']?['hierarchy'] ?? 'Referral Hierarchy';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title, style: const TextStyle(color: _greenDark, fontWeight: FontWeight.w700)),
        backgroundColor: _cream.withOpacity(.96),
        border: const Border(bottom: BorderSide(color: Colors.transparent)),
        trailing: _pill(
          label: t['common']?['refresh'] ?? 'Refresh',
          icon: CupertinoIcons.refresh,
          onPressed: () {
            setState(() => _loading = true);
            _fetchReferralData();
          },
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(heading, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _levelRow(t['referrals']?['firstLevel'] ?? 'First Level', _referrals['level_1'] ?? 0),
                      _levelRow(t['referrals']?['secondLevel'] ?? 'Second Level', _referrals['level_2'] ?? 0),
                      _levelRow(t['referrals']?['thirdLevel'] ?? 'Third Level', _referrals['level_3'] ?? 0),
                      _levelRow(t['referrals']?['fourthLevel'] ?? 'Fourth Level', _referrals['level_4'] ?? 0),
                      _levelRow(t['referrals']?['fifthLevel'] ?? 'Fifth Level', _referrals['level_5'] ?? 0),
                      _levelRow(t['referrals']?['sixthLevel'] ?? 'Sixth Level', _referrals['level_6'] ?? 0),
                      _levelRow(t['referrals']?['seventhLevel'] ?? 'Seventh Level', _referrals['level_7'] ?? 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
