import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config/environment_config.dart';
import 'screens/login_screen.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'tabs/tab4.dart';
import 'services/auth_service.dart';
import 'services/tutorial_service.dart';
import 'screens/tutorial_screen.dart';
import 'widgets/spotlight.dart';
import 'services/home_tutorial_flow.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> translations;
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;
  final int initialIndex;
  final bool isAuthenticated;

  const MyHomePage({
    Key? key,
    required this.translations,
    required this.onChangeLanguage,
    required this.currentLocale,
    this.initialIndex = 0,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

  final GlobalKey _payKey = GlobalKey();
  final GlobalKey _navMapKey     = GlobalKey();
  final GlobalKey _navProfileKey = GlobalKey();

  final GlobalKey _viewSwitchKey = GlobalKey();
  final GlobalKey _controlsKey   = GlobalKey();
  final GlobalKey _mapAreaKey    = GlobalKey();

  OverlayEntry? _spotlightEntry;

  late Spotlight _spotlight;

  String name = 'Name not available';
  String email = 'Email not available';
  String phone = 'Phone not available';
  String profilePhotoUrl = '';
  double points = 0;
  int totalReferrals = 0;

  @override
  void initState() {
    super.initState();
    _spotlight = Spotlight(context); // simple

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HomeTutorialFlow(TutorialService()).run(
        context: context,
        spotlight: _spotlight,
        viewSwitchKey: _viewSwitchKey,
        controlsKey: _controlsKey,
        mapAreaKey: _mapAreaKey,
        navProfileKey: _navProfileKey,
        navMapKey: _navMapKey,
        payKey: _payKey,
        setTabIndex: (i) => setState(() => _currentIndex = i),
        ensureMapTab: () => setState(() => _currentIndex = 0),
      );
    });

    if (widget.isAuthenticated) {
      _fetchUserDetails();
    } else {
      _performLogin();
    }
  }


  @override
  void dispose() {
    _spotlight.dismiss();
    super.dispose();
  }

  Future<void> _performLogin() async {
    try {
      final loginData = await _authService.login('usuario@example.com', 'password');
      if (loginData['success']) {
        _fetchUserDetails();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await _authService.fetchUserDetails();
      setState(() {
        name = userDetails['name'] ?? _getTranslation('common', 'noDataAvailable', 'Name not available');
        email = userDetails['email'] ?? _getTranslation('common', 'noDataAvailable', 'Email not available');
        phone = userDetails['phone'] ?? _getTranslation('common', 'noDataAvailable', 'Phone not available');
        profilePhotoUrl = userDetails['profile_photo_url'] ?? '';
      });

      final userData = await _authService.fetchUserData();
      setState(() {
        points = userData['points'] ?? 0.0;
        totalReferrals = (userData['totalReferrals'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  String _getTranslation(String section, String key, String fallback) {
    return widget.translations[section]?[key] ?? fallback;
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onChangeLanguage: widget.onChangeLanguage,
          currentLocale: widget.currentLocale,
          translations: widget.translations,
        ),
      ),
    );
  }

  void _navigateToTransactionTab() {
    setState(() {
      _currentIndex = 2;
    });
    Navigator.pop(context);
  }

  void _navigateToProfileTab() {
    setState(() {
      _currentIndex = 3;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.translations.isEmpty) {
      return const Center(child: Text('Translations not loaded'));
    }

    final tabs = <Widget>[
      Tab1(
        scaffoldKey: _scaffoldKey,
        isAuthenticated: widget.isAuthenticated,
        translations: widget.translations,
        onTapList: () => setState(() => _currentIndex = 1),

        viewSwitchKey: _viewSwitchKey,
        controlsKey: _controlsKey,
        mapAreaKey: _mapAreaKey,
      ),
      Tab2(translations: widget.translations),
      widget.isAuthenticated
          ? Tab3(
        translations: widget.translations,
        onChangeLanguage: widget.onChangeLanguage,
      )
          : _buildRestrictedAccess(),
      widget.isAuthenticated
          ? Tab4(
        translations: widget.translations,
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
      )
          : _buildRestrictedAccess(),
    ];

    return PopScope(
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 40),
          child: Container(
            margin: const EdgeInsets.only(bottom: 0),
            height: 128,
            width: 128,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF7EFE4), // Anillo extra del color de la barra
            ),
            child: Center(
              child: Container(
                height: 90,
                width: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF103D1B), // Borde externo verde oscuro
                ),
                child: Center(
                  child: Container(
                    height: 86,
                    width: 86,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Anillo blanco
                    ),
                    child: Center(
                      child: InkWell(
                        key: _payKey,
                        borderRadius: BorderRadius.circular(84),
                        onTap: () => setState(() => _currentIndex = 2),
                        child: Container(
                          height: 84,
                          width: 84,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF103D1B), // Interior verde oscuro
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.money_dollar_circle, size: 42, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 6.0,
          color: const Color(0xFFF7EFE4),
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bottomIcon(CupertinoIcons.map_fill, 'Map', 0, key: _navMapKey),
                const SizedBox(width: 90),
                _bottomIcon(CupertinoIcons.person_crop_circle_fill, 'Profile', 1, key: _navProfileKey),
              ],
            ),
          ),
        ),
        body: SafeArea(child: tabs[_currentIndex]),
        drawer: _buildDrawer(),
        endDrawer: _buildEndDrawer(),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, String label, int index, {Key? key}) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      key: key,
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 84.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF103D1B), size: 30),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF103D1B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: widget.isAuthenticated ? _buildProfileInfo() : _buildLoginButton(),
        ),
      ),
    );
  }

  Widget _buildEndDrawer() {
    return const Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [Text('Marker Information')]),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return CupertinoActionSheet(
      title: Text(_getTranslation('user', 'profile', 'User Profile')),
      message: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('user', 'name', name),
          _buildInfoRow('user', 'email', email),
          _buildInfoRow('user', 'phone', phone),
          _buildInfoRow('user', 'totalPoints', points.toString()),
          _buildInfoRow('user', 'totalReferrals', totalReferrals.toString()),
          if (profilePhotoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(profilePhotoUrl)),
            ),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(_getTranslation('transaction', 'generate', 'Generate Transaction')),
          onPressed: _navigateToTransactionTab,
        ),
        CupertinoActionSheetAction(
          child: Text(_getTranslation('user', 'modifyProfile', 'Modify Profile')),
          onPressed: _navigateToProfileTab,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(_getTranslation('common', 'close', 'Close')),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildInfoRow(String section, String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getTranslation(section, key, key)}:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(value, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _navigateToLogin,
        child: Text(_getTranslation('auth', 'login', 'Login')),
      ),
    );
  }

  Widget _buildRestrictedAccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getTranslation('auth', 'restrictedAccessMessage', 'Restricted Access'),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToLogin,
            child: Text(_getTranslation('auth', 'login', 'Login')),
          ),
        ],
      ),
    );
  }
}

