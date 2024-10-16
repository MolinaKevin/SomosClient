import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'referral_screen.dart';
import '../services/auth_service.dart';

class PointsScreen extends StatefulWidget {
  final Map<String, String> translations;

  const PointsScreen({super.key, required this.translations});

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int _points = 0;
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
        _points = data['points'] ?? 0;
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.translations['viewPoints'] ?? 'Ver Puntos'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CupertinoActivityIndicator())
              : _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.translations['failedToLoadData'] ?? 'Error al cargar datos',
                  style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 18),
                ),
                CupertinoButton(
                  child: Text(widget.translations['retry'] ?? 'Reintentar'),
                  onPressed: _fetchUserData,
                ),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${widget.translations['totalPoints'] ?? 'Total de Puntos'}:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '$_points', // Muestra los puntos dinámicos
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${widget.translations['referrals'] ?? 'Referidos'}:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${widget.translations['firstLevelReferrals'] ?? 'Primer Nivel'}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '$_firstLevelReferrals', // Muestra los referidos de primer nivel
                  style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${widget.translations['lowerLevelReferrals'] ?? 'Niveles Inferiores'}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  '$_lowerLevelReferrals', // Muestra los referidos de niveles inferiores
                  style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: CupertinoButton.filled(
                  onPressed: () => _navigateToReferralScreen(context),
                  child: Text(widget.translations['viewReferrals'] ?? 'Ver'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
