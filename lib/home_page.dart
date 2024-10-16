import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'tabs/tab4.dart';
import 'services/auth_service.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;
  final int initialIndex;
  final bool isAuthenticated;

  const MyHomePage({
    super.key,
    required this.translations,
    required this.onChangeLanguage,
    required this.currentLocale,
    this.initialIndex = 0,
    required this.isAuthenticated,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

  String name = 'Nombre no disponible';
  String email = 'Email no disponible';
  String phone = 'Teléfono no disponible';
  int points = 0;
  int totalReferrals = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _fetchUserData();
    } else {
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    try {
      final loginData = await _authService.login('usuario@example.com', 'password');

      if (loginData['success']) {
        _fetchUserData();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _authService.fetchUserData();
      setState(() {
        name = userData['name'] ?? widget.translations['noDataAvailable'] ?? 'Nombre no disponible';
        email = userData['email'] ?? widget.translations['noDataAvailable'] ?? 'Email no disponible';
        phone = userData['phone'] ?? widget.translations['noDataAvailable'] ?? 'Teléfono no disponible';
        points = userData['points'] ?? 0;
        totalReferrals = userData['totalReferrals'] ?? 0;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen(
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
        translations: widget.translations, // O asegúrate de pasar las traducciones correctas
      )),
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
    final List<String> _tabTitles = [
      widget.translations['map'] ?? 'Mapa',
      widget.translations['list'] ?? 'Lista',
      widget.translations['pointsTab'] ?? 'Puntos',
      widget.translations['profile'] ?? 'Perfil',
    ];

    List<Widget> tabs = [
      Tab1(scaffoldKey: _scaffoldKey, isAuthenticated: widget.isAuthenticated, translations: widget.translations), // Pasar translations
      Tab2(translations: widget.translations),
      widget.isAuthenticated
          ? Tab3(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage)
          : _buildRestrictedAccess(),
      widget.isAuthenticated
          ? Tab4(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage, currentLocale: widget.currentLocale)
          : _buildRestrictedAccess(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CupertinoNavigationBar(
          middle: Text(_tabTitles[_currentIndex]),
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(CupertinoIcons.bars),
              );
            },
          ),
          trailing: _currentIndex == 1
              ? Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: const Icon(CupertinoIcons.search),
              );
            },
          )
              : null,
        ),
        body: SafeArea(
          child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.map),
                  label: widget.translations['map'] ?? 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.phone),
                  label: widget.translations['list'] ?? 'Lista',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.bitcoin),
                  label: widget.translations['pointsTab'] ?? 'Puntos',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.profile_circled),
                  label: widget.translations['profile'] ?? 'Perfil',
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            tabBuilder: (BuildContext context, int index) {
              return tabs[_currentIndex];
            },
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: SingleChildScrollView(
              child: widget.isAuthenticated
                  ? _buildProfileInfo()
                  : _buildLoginButton(),
            ),
          ),
        ),
        endDrawer: const Drawer(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Información del marcador'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return CupertinoActionSheet(
      title: Text(widget.translations['userProfile'] ?? 'Perfil de usuario'),
      message: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.translations['name'] ?? 'Nombre'}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(name, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text('${widget.translations['email'] ?? 'Correo electrónico'}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text('${widget.translations['phone'] ?? 'Teléfono'}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(phone, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text('${widget.translations['points'] ?? 'Puntos'}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(points.toString(), style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text('${widget.translations['totalReferrals'] ?? 'Referidos'}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(totalReferrals.toString(), style: const TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(widget.translations['generateTransaction'] ?? 'Generar Transacción'),
          onPressed: _navigateToTransactionTab,
        ),
        CupertinoActionSheetAction(
          child: Text(widget.translations['userProfile'] ?? 'Perfil de usuario'),
          onPressed: _navigateToProfileTab,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(widget.translations['close'] ?? 'Cerrar'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _navigateToLogin,
        child: Text(widget.translations['login'] ?? 'Iniciar sesión'),
      ),
    );
  }

  Widget _buildRestrictedAccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.translations['restricted_access_message'] ?? 'Acceso restringido',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToLogin,
            child: Text(widget.translations['login'] ?? 'Iniciar sesión'),
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
