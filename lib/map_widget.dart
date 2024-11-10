import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async'; // Para el debounce con Timer
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http; // Para hacer solicitudes HTTP
import 'services/commerce_service.dart';
import 'services/institution_service.dart';
import 'services/auth_service.dart';
import 'screens/entity_detail_screen.dart';

class MyMapWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;
  final Map<String, dynamic> translations; // Añadido para traducciones

  const MyMapWidget({required this.scaffoldKey, required this.isAuthenticated, required this.translations});

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isAuthenticated = false;
  int _points = 0;
  List<Map<String, dynamic>> markerData = [];
  final CommerceService commerceService = CommerceService();
  final InstitutionService institutionService = InstitutionService();
  final AuthService authService = AuthService();

  bool _isSearching = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchSuggestions = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchData();
    setState(() {});
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    final commerces = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
    final institutions = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);
    final userData = await authService.fetchUserData();

    setState(() {
      markerData = [
        ...commerces.map((commerce) => {
          'id': commerce['id'],
          'name': commerce['name'] ?? widget.translations['noDataAvailable'] ?? 'Nombre no disponible',
          'latitude': double.tryParse(commerce['latitude'] ?? '') ?? 0.0,
          'longitude': double.tryParse(commerce['longitude'] ?? '') ?? 0.0,
          'is_open': commerce['is_open'] ?? false,
          'avatar': commerce['avatar'],
          'avatar_url': commerce['avatar_url'],
          'background_image': commerce['background_image'] ?? '',
          'fotos_urls': commerce['fotos_urls'] ?? [],
        }).toList(),
        ...institutions.map((institution) => {
          'id': institution['id'],
          'name': institution['name'] ?? widget.translations['noDataAvailable'] ?? 'Nombre no disponible',
          'address': institution['address'] ?? widget.translations['noAddress'] ?? 'Dirección no disponible',
          'phone': institution['phone_number'] ?? widget.translations['noPhone'] ?? 'Teléfono no disponible',
          'email': institution['email'] ?? widget.translations['noEmail'] ?? 'Correo no disponible',
          'city': institution['city'] ?? widget.translations['noCity'] ?? 'Ciudad no disponible',
          'description': institution['description'] ?? widget.translations['noDescription'] ?? 'Descripción no disponible',
          'latitude': double.tryParse(institution['latitude'] ?? '') ?? 0.0,
          'longitude': double.tryParse(institution['longitude'] ?? '') ?? 0.0,
          'is_open': institution['is_open'] ?? false,
          'avatar': institution['avatar'],
          'avatar_url': institution['avatar_url'],
          'background_image': institution['background_image'] ?? '',
          'fotos_urls': institution['fotos_urls'] ?? [],
        }).toList(),
      ];

      _points = userData['points'] ?? 0;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchSuggestions.clear();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      _updateSearchSuggestions(query);
    });
  }

  Future<void> _updateSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          _searchSuggestions = results;
        });
      } else {
        print('Error al obtener sugerencias de búsqueda');
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchSuggestions.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                urlTemplate: 'https://abcd.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
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
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.black),
                        onPressed: _toggleSearch,
                      ),
                      IconButton(
                        icon: Icon(Icons.zoom_in, color: Colors.green),
                        onPressed: () {
                          mapController.move(
                              mapController.center, mapController.zoom + 1);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.zoom_out, color: Colors.red),
                        onPressed: () {
                          mapController.move(
                              mapController.center, mapController.zoom - 1);
                        },
                      ),
                    ],
                  ),
                ),
                if (_isSearching)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        children: [
                          Container(
                            height: 48,
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: widget.translations['search'] ?? 'Buscar...',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: _onSearchChanged,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  onPressed: _toggleSearch,
                                ),
                              ],
                            ),
                          ),
                          if (_searchSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
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
                                children: _searchSuggestions.map((suggestion) {
                                  return ListTile(
                                    title: Text(suggestion['display_name']),
                                    onTap: () {
                                      double lat = double.parse(suggestion['lat']);
                                      double lon = double.parse(suggestion['lon']);
                                      mapController.move(LatLng(lat, lon), 15.0);
                                      _toggleSearch();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
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
                    widget.translations['points'] ?? "Puntos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isAuthenticated ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                    ),
                  ),
                  Text(
                    _points.toString(),
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
    return markerData.map((data) {
      double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
      double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

      return Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EntityDetailScreen(
                        title: data['name'] ?? widget.translations['noDataAvailable'] ?? 'No disponible',
                        address: data['address'] ?? widget.translations['noAddress'] ?? 'No disponible',
                        phone: data['phone'] ?? widget.translations['noPhone'] ?? 'No disponible',
                        email: data['email'] ?? widget.translations['noEmail'] ?? 'Correo no disponible',
                        city: data['city'] ?? widget.translations['noCity'] ?? 'Ciudad no disponible',
                        description: data['description'] ?? widget.translations['noDescription'] ?? 'Descripción no disponible',
                        imageUrl: data['avatar_url'] ?? '',
                        backgroundImage: data['background_image'] ?? '',
                        fotosUrls: List<String>.from(data['fotos_urls'] ?? []),
                        translations: widget.translations,  // Asegúrate de pasar las traducciones aquí
                      ),
                    ),
                  );

                },
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
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2 * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(data['background_image'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 0, top: 100),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(data['avatar_url'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 0),
                        child: Row(
                          children: [
                            Icon(
                              data['is_open'] == true ? Icons.check : Icons.close,
                              color: data['is_open'] == true ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              data['is_open'] == true ? widget.translations['open'] ?? 'Abierto' : widget.translations['closed'] ?? 'Cerrado',
                              style: TextStyle(
                                color: data['is_open'] == true ? Colors.green : Colors.red,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                        child: Text(
                          data['name'] ?? widget.translations['noDataAvailable'] ?? 'No disponible',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
}
