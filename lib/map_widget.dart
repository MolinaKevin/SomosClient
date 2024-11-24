import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'controllers/map_controller.dart';
import 'widgets/map_controls_widget.dart';
import 'popups/popup_categories.dart';
import 'widgets/marker_widget.dart';
import 'popups/popup_info_card.dart';

class MyMapWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;
  final Map<String, dynamic> translations;

  const MyMapWidget({
    Key? key,
    required this.scaffoldKey,
    required this.isAuthenticated,
    required this.translations,
  }) : super(key: key);

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final MapDataController dataController = MapDataController();

  List<Map<String, dynamic>> selectedCategories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await dataController.initializeData(translations: widget.translations);
    setState(() {});
  }

  void _showFilterPopup() {
    PopupCategories.show(
      context: context,
      translations: widget.translations,
      categories: dataController.categories,
      onCategorySelected: selectCategory,
      selectedCategories: selectedCategories,
    );
  }

  void applyFilters() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (selectedCategories.isEmpty) {
        // Si no hay categorías seleccionadas, cargamos todos los comercios
        await dataController.fetchData(
            translations: widget.translations, forceRefresh: true);
      } else {
        // Obtener los marcadores filtrados
        await dataController.fetchFilteredMarkers(
            selectedCategories, translations: widget.translations);
      }

      setState(() {
        // Actualizamos los marcadores en el mapa
      });
    } catch (e) {
      // Manejar errores
      print('Error fetching filtered commerces: $e');
      // Mostrar mensaje de error al usuario
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to apply filters. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void selectCategory(Map<String, dynamic> category) {
    setState(() {
      int index = selectedCategories.indexWhere((c) => c['id'] == category['id']);
      if (index >= 0) {
        selectedCategories.removeAt(index);
      } else {
        selectedCategories.add(category);
      }
    });
    applyFilters();
  }


  void _onMarkerTap(BuildContext context, Map<String, dynamic> data) {
    setState(() {
      activeMarker = data['id'].toString();
    });

    InfoCardPopup.show(
      context: context,
      data: data,
      translations: widget.translations,
      onDismiss: () {
        setState(() {
          activeMarker = '';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = MarkerWidget.createMarkers(
      context: context,
      markerData: dataController.markerData,
      activeMarker: activeMarker,
      onMarkerTap: _onMarkerTap,
    );

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
                urlTemplate:
                'https://abcd.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          // Agregamos el Row de categorías seleccionadas
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedCategories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      selectCategory(category);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          Text(
                            category['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.close, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 10,
            right: 180,
            child: MapControlsWidget(
              mapController: mapController,
              translations: widget.translations,
              showFilterPopup: _showFilterPopup,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
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
                    widget.translations['user']?['totalPoints'] ?? "Points",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isAuthenticated
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.destructiveRed,
                    ),
                  ),
                  Text(
                    dataController.points.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isAuthenticated
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.destructiveRed,
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
}
