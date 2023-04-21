import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Tabs with Map Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  List<Widget> _tabs = [
    Tab1(),
    Tab2(),
    Tab3(),
  ];

  List<String> _tabTitles = [
    'Mapa',
    'Lista',
    'Perfil'
  ];

  Widget _buildProfileInfo() {
    return CupertinoActionSheet(
      title: Text('Perfil de usuario'),
      message: Column(
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
        child: Text('Cerrar'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_tabTitles[_currentIndex]),
        leading: GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => _buildProfileInfo(),
            );
          },
          child: Icon(CupertinoIcons.bars),
        ),
      ),
      child: SafeArea(
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
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
            return _tabs[_currentIndex];
          },
        ),
      ),
    );
  }
}

class Tab1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(51.541280, 9.915804), // Coordenadas de Göttingen
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
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
                  leading: Icon(CupertinoIcons.circle_fill,
                      color: CupertinoColors.activeBlue),
                  title: Text(_tarjetas[index]),
                  trailing: Icon(CupertinoIcons.chevron_forward),
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
  void _showModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Información'),
        message: Text('Esta es una prueba.'),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cerrar'),
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
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showModal(context),
                        child: CircleAvatar(
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
