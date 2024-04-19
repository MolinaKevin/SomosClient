import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

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
          () => Navigator.pushReplacement(
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

void main() {
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final List<String> _tabTitles = [
    'Mapa',
    'Lista',
    'Perfil'
  ];

  Widget _buildProfileInfo() {
    return CupertinoActionSheet(
      title: const Text('Perfil de usuario'),
      message: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Juan Pérez',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            'Correo electrónico:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'juan.perez@example.com',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            'Teléfono:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '+1 234 567 8900',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cerrar'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      Tab1(scaffoldKey: _scaffoldKey),
      const Tab2(),
      const Tab3(),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.map),
                label: 'Mapa',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.phone),
                label: 'Tab 2',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled),
                label: 'Tab 3',
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
            child: _buildProfileInfo(),
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
}

class Tab1 extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Tab1({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: FlutterMap(
            options: MapOptions(
              center: const LatLng(51.534709, 9.932835), // Coordenadas de Göttingen
              zoom: 13.0,
              //plugins: [
              //  MarkerClusterPlugin(),
              //],
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: const Size(40, 40),
                fitBoundsOptions: const FitBoundsOptions(
                  padding: EdgeInsets.all(50),
                ),
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: const LatLng(51.534709, 9.932835),
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
                polygonOptions: const PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3,
                ),
                builder: (context, markers) {
                  return FloatingActionButton(
                    onPressed: null,
                    child: Text(markers.length.toString()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class Tab2 extends StatelessWidget {
  final List<String> _tarjetas = [
    'Tarjeta 1',
    'Tarjeta 2',
    'Tarjeta 3',
    'Tarjeta 4',
    'Tarjeta 5',
  ];

  const Tab2({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: ListView.builder(
            itemCount: _tarjetas.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  leading: const Icon(CupertinoIcons.circle_fill,
                      color: CupertinoColors.activeBlue),
                  title: Text(_tarjetas[index]),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
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
  const Tab3({super.key});

  void _showModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Información'),
        message: const Text('Esta es una prueba.'),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cerrar'),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Juan Pérez',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Correo electrónico:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'juan.perez@example.com',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Teléfono:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+1 234 567 8900',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Teléfono:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+1 234 567 8900123996623123',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
