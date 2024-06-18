import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: loadTranslations(_locale),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Error loading translations: ${snapshot.error}');
          return const Center(child: Text('Error loading translations'));
        }
        final translations = snapshot.data!;
        return MaterialApp(
          locale: _locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('de', ''),
          ],
          debugShowCheckedModeBanner: false,
          home: MyHomePage(
            translations: translations,
            onChangeLanguage: _changeLanguage,
          ),
        );
      },
    );
  }
}

Future<Map<String, String>> loadTranslations(Locale locale) async {
  try {
    final String jsonString = await rootBundle.loadString('lib/l10n/intl_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    print('Error loading JSON file: $e');
    throw e;
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString =
    await rootBundle.loadString('lib/l10n/intl_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () =>
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/somos_splash.png'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const MyHomePage({super.key, required this.translations, required this.onChangeLanguage});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<String> _tabTitles = [
      localizations.translate('map'),
      localizations.translate('list'),
      localizations.translate('points'),
      localizations.translate('buy'),
      localizations.translate('generateTransaction'),
    ];

    List<Widget> tabs = [
      Tab1(scaffoldKey: _scaffoldKey),
      Tab2(translations: widget.translations),
      Tab3(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage),
      Tab4(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage),
    ];

    return Scaffold(
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
                label: localizations.translate('map'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.phone),
                label: localizations.translate('list'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.bitcoin),
                label: localizations.translate('points'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.profile_circled),
                label: localizations.translate('profile'),
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
            child: _buildProfileInfo(localizations),
          ),
        ),
      ),
      endDrawer: const Drawer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Información del marcador')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AppLocalizations localizations) {
    return CupertinoActionSheet(
      title: Text(localizations.translate('userProfile')),
      message: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${localizations.translate('name')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Juan Pérez',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('email')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'juan.perez@example.com',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('phone')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '+1 234 567 8900',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('points')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '25555',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      cancelButton: CupertinoActionSheetAction(
        child: Text(localizations.translate('description')),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class Tab1 extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Tab1({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return MyMapWidget(scaffoldKey: scaffoldKey);
  }
}

class MyMapWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MyMapWidget({required this.scaffoldKey});

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _showInfoCard(BuildContext context, Map<String, dynamic> data) {
    setState(() {
      activeMarker = data['id'].toString();
    });
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent, // Hace que el fondo sea transparente
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: MediaQuery.of(context).size.height * 0.1 * 0.7, // margen inferior para evitar los íconos
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.2, // Limita la altura del popup al 40% de la pantalla
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parte superior con imagen de fondo y avatar
                    Stack(
                      children: [
                        // Imagen de fondo
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.1 * 0.9,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(data['backgroundImage']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                          ),
                        ),
                        // Avatar centrado
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(data['avatar']),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Parte inferior que ocupa 1/4 del popup
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 0), // Ajusta el valor según sea necesario
                      child: Row(
                        children: [
                          Icon(
                              data['icon'],
                              color: data['isOpen'] ? Colors.green : Colors.red,
                              size: 15
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data['isOpen'] ? Colors.green : Colors.red,                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                              data['isOpen'] ? 'Abierto' : 'Cerrado',
                              style: TextStyle(
                                  color: data['isOpen'] ? Colors.green : Colors.red,
                                  fontSize: 14
                              )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 10.0), // Ajusta el valor según sea necesario
                      child: Text(
                        'Nombre del Local',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ).drive(Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          )),
          child: child,
        );
      },
    ).then((_) {
      setState(() {
        activeMarker = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> markerData = [
      {
        'id': 1,
        'point': LatLng(51.534709, 9.932835),
        'name': 'Café Central',
        'isOpen': true,
        'icon': Icons.local_cafe,
        'avatar': 'https://marketplace.canva.com/EAFg-hSdo4k/2/0/1600w/canva-logotipo-boutique-moderno-blanco-y-negro-B7irPhi64eA.jpg',
        'backgroundImage': 'https://www.kozoarquitectura.es/wp-content/uploads/2018/09/imagen-marca-local-tienda.jpg',
      },
      {
        'id': 2,
        'point': LatLng(51.514709, 9.952835),
        'name': 'Library',
        'isOpen': false,
        'icon': Icons.local_library,
        'avatar': 'https://marketplace.canva.com/EAFg-hSdo4k/2/0/1600w/canva-logotipo-boutique-moderno-blanco-y-negro-B7irPhi64eA.jpg',
        'backgroundImage': 'https://lasillarota.com/u/fotografias/m/2023/11/2/f425x230-510604_524586_5050.jpeg',
      },
      {
        'id': 3,
        'point': LatLng(51.524709, 9.922835),
        'name': 'Restaurant',
        'isOpen': true,
        'icon': Icons.restaurant,
        'avatar': 'https://marketplace.canva.com/EAFg-hSdo4k/2/0/1600w/canva-logotipo-boutique-moderno-blanco-y-negro-B7irPhi64eA.jpg',
        'backgroundImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNtTmYvwcJvTg_dzCIF8DlBVruDgpnU0OM5Q&s',
      },
    ];

    final markers = createMarkers(context, markerData);

    return CupertinoPageScaffold(
      child: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(51.534709, 9.932835), // Coordenadas de Göttingen
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }

  List<Marker> createMarkers(BuildContext context, List<Map<String, dynamic>> markerData) {
    return markerData.map((data) {
      return Marker(
        point: data['point'],
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _showInfoCard(context, data),
          child: Image.asset(
            activeMarker == data['id'].toString() ? 'assets/images/active_marker.png' : 'assets/images/map_marker.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }).toList();
  }
}

class Tab2 extends StatelessWidget {
  final Map<String, String> translations;

  const Tab2({super.key, required this.translations});

  final List<Map<String, String>> _tarjetas = const [
    {
      'title': 'Institución Ejemplo 1',
      'address': 'Calle Falsa 123',
      'phone': '+1 234 567 890',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 2',
      'address': 'Avenida Siempre Viva 456',
      'phone': '+1 234 567 891',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 3',
      'address': 'Boulevard de los Sueños 789',
      'phone': '+1 234 567 892',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 4',
      'address': 'Plaza de la Constitución 101',
      'phone': '+1 234 567 893',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 5',
      'address': 'Calle de la Rosa 202',
      'phone': '+1 234 567 894',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: ListView.builder(
            itemCount: _tarjetas.length,
            itemBuilder: (BuildContext context, int index) {
              final tarjeta = _tarjetas[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    tarjeta['image']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(tarjeta['title']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${translations['address']}: ${tarjeta['address']}'),
                      Text('${translations['phone']}: ${tarjeta['phone']}'),
                    ],
                  ),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  onTap: () {
                    // Lógica para ir a la descripción (sin función actualmente)
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Tab3 extends StatelessWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab3({super.key, required this.translations, required this.onChangeLanguage});

  void _navigateToReferralScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ReferralScreen(translations: translations)),
    );
  }

  void _navigateToTransactionScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TransactionScreen(translations: translations)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '${translations['totalPoints'] ?? 'Total de Puntos'}:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '25555', // Esta cantidad debería ser dinámica
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${translations['referral'] ?? 'Referidos'}:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${translations['firstLevelReferrals'] ?? 'Primer Nivel'}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '10', // Esta cantidad debería ser dinámica
                            style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${translations['lowerLevelReferrals'] ?? 'Niveles Inferiores'}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '25', // Esta cantidad debería ser dinámica
                            style: TextStyle(fontSize: 24, color: CupertinoColors.activeBlue),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          CupertinoButton.filled(
                            onPressed: () => _navigateToReferralScreen(context),
                            child: Text(translations['viewReferrals'] ?? 'Ver'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  CupertinoButton.filled(
                    onPressed: () => _navigateToTransactionScreen(context),
                    child: Text(translations['generateTransaction'] ?? 'Generar Transacción'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReferralScreen extends StatelessWidget {
  final Map<String, String> translations;

  const ReferralScreen({super.key, required this.translations});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translations['viewReferrals'] ?? 'Ver Referidos'),
      ),
      child: Center(
        child: Text('Detalles de los referidos aquí'),
      ),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final Map<String, String> translations;

  const TransactionScreen({super.key, required this.translations});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _amount = '';

  void _onKeyTapped(String key) {
    setState(() {
      if (key == 'C') {
        _amount = '';
      } else if (key == '←') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        if (_amount.contains('.') && key == '.') return;
        if (_amount.split('.').length == 2 && _amount.split('.')[1].length >= 2) return;
        _amount += key;
      }
    });
  }

  void _initiateNFC() {
    // Lógica para iniciar NFC
    print('Iniciando NFC para $_amount€');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.translations['generateTransaction'] ??
            'Generar Transacción'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  '€$_amount',
                  style: TextStyle(fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeGreen),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: [
                      '1', '2', '3',
                      '4', '5', '6',
                      '7', '8', '9',
                      '.', '0', '←',
                    ].map((key) {
                      return AspectRatio(
                        aspectRatio: 1,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(4.0),
                          color: CupertinoColors.systemGrey,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(key, style: TextStyle(
                                fontSize: 18)),
                          ),
                          onPressed: () => _onKeyTapped(key),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: _amount.isNotEmpty ? _initiateNFC : null,
                  child: Text(widget.translations['initiateTransaction'] ??
                      'Iniciar Transacción'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Tab4 extends StatelessWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab4({super.key, required this.translations, required this.onChangeLanguage});

  void _showModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(translations['information'] ?? 'Información'),
        message: Text(translations['thisIsTest'] ?? 'Esta es una prueba.'),
        cancelButton: CupertinoActionSheetAction(
          child: Text(translations['close'] ?? 'Cerrar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${translations['name'] ?? 'Nombre'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Juan Pérez',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['email'] ?? 'Correo electrónico'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'juan.perez@example.com',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['phone'] ?? 'Teléfono'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+1 234 567 8900',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['points'] ?? 'Puntos'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '25555',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showModal(context),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150'), // URL de la imagen de perfil
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        // Lógica para modificar el perfil (sin función actualmente)
                      },
                      child: Text(translations['modifyProfile'] ?? 'Modificar perfil'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('en'));
                      },
                      child: const Text('English'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('es'));
                      },
                      child: const Text('Español'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('de'));
                      },
                      child: const Text('Deutsch'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
