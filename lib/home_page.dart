import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'tabs/tab4.dart';
import 'services/auth_service.dart';

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

  String name = 'Name not available';
  String email = 'Email not available';
  String phone = 'Phone not available';
  String profilePhotoUrl = '';
  double points = 0;
  int totalReferrals = 0;

  @override
  void initState() {
    super.initState();
    print('Current language code: ${widget.currentLocale.languageCode}');
    if (widget.isAuthenticated) {
      _fetchUserDetails();
    } else {
      _performLogin();
    }
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
      print('Error fetching user data: $e');
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
    // Validación temprana
    if (widget.translations == null) {
      return Center(child: Text('Translations not loaded'));
    }

    final List<String> _tabTitles = [
      _getTranslation('navigation', 'map', 'Map'),
      _getTranslation('navigation', 'list', 'List'),
      _getTranslation('navigation', 'pointsTab', 'Points'),
      _getTranslation('navigation', 'profile', 'Profile'),
    ];

    List<Widget> tabs = [
      Tab1(
        scaffoldKey: _scaffoldKey,
        isAuthenticated: widget.isAuthenticated,
        translations: widget.translations,
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CupertinoNavigationBar(
          middle: Text(_tabTitles[_currentIndex]),
        ),
        body: SafeArea(
          child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.map),
                  label: _getTranslation('navigation', 'map', 'Map'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.phone),
                  label: _getTranslation('navigation', 'list', 'List'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.bitcoin),
                  label: _getTranslation('navigation', 'pointsTab', 'Points'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.profile_circled),
                  label: _getTranslation('navigation', 'profile', 'Profile'),
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) => setState(() {
                _currentIndex = index;
              }),
            ),
            tabBuilder: (BuildContext context, int index) {
              return tabs[_currentIndex];
            },
          ),
        ),
        drawer: _buildDrawer(),
        endDrawer: _buildEndDrawer(),
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
          child: Column(
            children: [
              Text('Marker Information'),
            ],
          ),
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
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePhotoUrl),
              ),
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

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return true;
  }
}
