import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
                  maxHeight: MediaQuery.of(context).size.height * 0.2,
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
                      padding: const EdgeInsets.only(left: 16.0, top: 0),
                      child: Row(
                        children: [
                          Icon(
                            data['icon'],
                            color: data['isOpen'] ? Colors.green : Colors.red,
                            size: 15,
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
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                      child: Text(
                        data['name'],
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
