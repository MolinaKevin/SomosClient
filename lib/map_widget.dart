import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'controllers/map_controller.dart';
import 'widgets/map_controls_widget.dart';
import 'popups/popup_categories.dart';
import 'popups/popup_seals.dart';
import 'widgets/marker_widget.dart';
import 'popups/popup_info_card.dart';

class MyMapWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAuthenticated;
  final Map<String, dynamic> translations;
  final VoidCallback onTapList;

  final GlobalKey? viewSwitchKey;
  final GlobalKey? controlsKey;
  final GlobalKey? mapAreaKey;

  const MyMapWidget({
    Key? key,
    required this.scaffoldKey,
    required this.isAuthenticated,
    required this.translations,
    required this.onTapList,
    this.viewSwitchKey,
    this.controlsKey,
    this.mapAreaKey,
  }) : super(key: key);

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final MapDataController dataController = MapDataController();

  List<Map<String, dynamic>> selectedSeals = [];
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

  void applyFilters() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (selectedSeals.isEmpty && selectedCategories.isEmpty) {
        await dataController.fetchData(
          translations: widget.translations,
          forceRefresh: true,
        );
      } else {
        final selectedItems = [...selectedSeals, ...selectedCategories];

        List<Map<String, dynamic>> seals = [];
        List<Map<String, dynamic>> categories = [];

        for (var item in selectedItems) {
          if (item.containsKey('state')) {
            seals.add(item);
          } else if (item.containsKey('slug') || item.containsKey('children')) {
            categories.add(item);
          }
        }

        final combinedFilters = {
          'seals': seals,
          'categories': categories,
        };

        await dataController.fetchFilteredMarkers(
          combinedFilters,
          translations: widget.translations,
        );
      }

      setState(() {});
    } catch (e) {
      print('Error applying filters: $e');
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

  void _selectSeal(Map<String, dynamic> seal) {
    setState(() {
      int index = selectedSeals.indexWhere((s) => s['id'] == seal['id']);
      if (index >= 0) {
        selectedSeals.removeAt(index);
      } else {
        selectedSeals.add(seal);
      }
    });
    applyFilters();
  }

  void _showFilterPopup() {
    PopupCategories.show(
      context: context,
      translations: widget.translations,
      categories: dataController.categories,
      selectedCategories: selectedCategories,
      onItemSelected: (item, type) {
        if (type == 'category') {
          _selectCategory(item);
        }
      },
    );
  }

  void _showSealPopup() {
    PopupSeals.show(
      context: context,
      seals: dataController.seals,
      selectedSeals: selectedSeals,
      onSealStateChanged: (updatedSeals) {
        setState(() {
          selectedSeals = updatedSeals
              .where((seal) => seal['state'] != 'none')
              .map((seal) => {
            'id': seal['id'],
            'name': seal['name'],
            'state': seal['state'],
          })
              .toList();
        });
        applyFilters();
      },
    );
  }

  void _selectCategory(Map<String, dynamic> category) {
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
      allSeals: dataController.seals,
      onDismiss: () {
        setState(() {
          activeMarker = '';
        });
      },
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = index == 0;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          widget.onTapList();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
                decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
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
          Positioned.fill(
            child: Container(
              key: widget.mapAreaKey,
              child: FlutterMap(
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
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            key: widget.viewSwitchKey,
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Map', 0),
                const SizedBox(width: 84),
                _buildTabButton('List', 1),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...selectedSeals.map((seal) {
                    return _buildSelectedItem(seal, 'seal');
                  }).toList(),
                  ...selectedCategories.map((category) {
                    return _buildSelectedItem(category, 'category');
                  }).toList(),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            right: 10,
            child: KeyedSubtree(
              key: widget.controlsKey,
              child: MapControlsWidget(
                mapController: mapController,
                translations: widget.translations,
                showFilterPopup: _showFilterPopup,
                showSealPopup: _showSealPopup,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 10,
            width: 150,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
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

  Widget _buildSelectedItem(Map<String, dynamic> item, String type) {
    return GestureDetector(
      onTap: () {
        if (type == 'seal') {
          _selectSeal(item);
        } else if (type == 'category') {
          _selectCategory(item);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Text(
              type == 'seal' ? "${item['name']}: ${item['state']}" : item['name'],
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
