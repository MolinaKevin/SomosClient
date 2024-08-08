import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyMapWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;

  const MyMapWidget({required this.scaffoldKey, required this.isAuthenticated});

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isAuthenticated = false;
  String _points = '';
  List<Map<String, dynamic>> markerData = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _updatePoints();
    _fetchCommerces();
  }

  void _updatePoints() {
    setState(() {
      _points = widget.isAuthenticated ? '1234' : 'No autenticado';
    });
  }

  Future<void> _fetchCommerces() async {
    final url = Uri.parse('http://localhost/api/commerces');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        markerData = data.map<Map<String, dynamic>>((commerce) {
          final entity = commerce['entity'];
          return {
            'id': commerce['id'],
            'point': LatLng(double.parse(entity['latitude']), double.parse(entity['longitude'])),
            'name': entity['name'],
            'isOpen': entity['is_open'],
            'icon': Icons.local_cafe,
            'avatar': entity['avatar'],
            'backgroundImage': entity['background_image'],
          };
        }).toList();
      });
      print('Marker data: $markerData');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _showInfoCard(BuildContext context, Map<String, dynamic> data) {
    setState(() {
      activeMarker = data['id'].toString();
    });
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: MediaQuery.of(context).size.height * 0.1 * 0.7,
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
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                          height: MediaQuery.of(context).size.height * 0.2 * 0.9,
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
                            margin: EdgeInsets.only(bottom:0,top:100),
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
                      padding: const EdgeInsets.only(left: 16.0, top: 0),
                      child: Row(
                        children: [
                          Icon(
                            data['icon'],
                            color: data['isOpen'] ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data['isOpen'] ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            data['isOpen'] ? 'Abierto' : 'Cerrado',
                            style: TextStyle(
                              color: data['isOpen'] ? Colors.green : Colors.red,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                      child: Text(
                        data['name'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
    print('Building markers with data: $markerData');
    final markers = createMarkers(context, markerData);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(51.534709, 9.932835),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            width: 150,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Puntos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isAuthenticated ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                    ),
                  ),
                  Text(
                    _points,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isAuthenticated ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> createMarkers(BuildContext context, List<Map<String, dynamic>> markerData) {
    print('Creating markers...');
    return markerData.map((data) {
      print('Creating marker for data: $data');
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
