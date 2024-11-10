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

  @override
  void initState() {
    super.initState();
    _fetchReferralData();
  }

  Future<void> _fetchReferralData() async {
    try {
      final data = await _authService.fetchUserData();
      setState(() {
        final referrals = data['referrals'] ?? {};
        _referrals = {
          'level_1': referrals['level_1'] ?? 0,
          'level_2': referrals['level_2'] ?? 0,
          'level_3': referrals['level_3'] ?? 0,
          'level_4': referrals['level_4'] ?? 0,
          'level_5': referrals['level_5'] ?? 0,
          'level_6': referrals['level_6'] ?? 0,
          'level_7': referrals['level_7'] ?? 0,
        };
      });
    } catch (e) {
      print('Failed to load referral data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.translations['referrals']['view'] ?? 'View Referrals'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  widget.translations['referrals']['hierarchy'] ?? 'Referral Hierarchy',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildReferralLevel(context, widget.translations['referrals']['firstLevel'] ?? 'First Level', _referrals['level_1'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['secondLevel'] ?? 'Second Level', _referrals['level_2'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['thirdLevel'] ?? 'Third Level', _referrals['level_3'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['fourthLevel'] ?? 'Fourth Level', _referrals['level_4'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['fifthLevel'] ?? 'Fifth Level', _referrals['level_5'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['sixthLevel'] ?? 'Sixth Level', _referrals['level_6'] ?? 0),
                      _buildReferralLevel(context, widget.translations['referrals']['seventhLevel'] ?? 'Seventh Level', _referrals['level_7'] ?? 0),
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

  Widget _buildReferralLevel(BuildContext context, String levelName, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            levelName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.activeGreen,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
