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

import 'widgets/map_tile_layer.dart';
import 'widgets/view_switch_bar.dart';
import 'widgets/selected_filters_bar.dart';
// import 'widgets/points_card.dart';
import 'ui/responsive.dart';

const bool kUseLocalTiles = false;

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
  State<MyMapWidget> createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late final MapController mapController;
  String activeMarker = '';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
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
    debugPrint('🟡 _initializeData() START');
    try {
      await dataController.initializeData(translations: widget.translations);
      debugPrint('🟢 OK. markers=${dataController.markerData.length}');
    } catch (e, st) {
      debugPrint('🔴 ERROR: $e\n$st');
    } finally {
      if (mounted) setState(() {});
      debugPrint('🔵 _initializeData() END');
    }
  }

  Future<void> applyFilters() async {
    setState(() => isLoading = true);
    try {
      if (selectedSeals.isEmpty && selectedCategories.isEmpty) {
        await dataController.fetchData(
          translations: widget.translations,
          forceRefresh: true,
        );
      } else {
        final seals = <Map<String, dynamic>>[];
        final categories = <Map<String, dynamic>>[];
        for (final item in [...selectedSeals, ...selectedCategories]) {
          if (item.containsKey('state')) {
            seals.add(item);
          } else if (item.containsKey('slug') || item.containsKey('children')) {
            categories.add(item);
          }
        }
        await dataController.fetchFilteredMarkers(
          {'seals': seals, 'categories': categories},
          translations: widget.translations,
        );
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error applying filters: $e');
      _showErrorDialog();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _selectSeal(Map<String, dynamic> seal) {
    setState(() {
      final i = selectedSeals.indexWhere((s) => s['id'] == seal['id']);
      if (i >= 0) {
        selectedSeals.removeAt(i);
      } else {
        selectedSeals.add(seal);
      }
    });
    applyFilters();
  }

  void _selectCategory(Map<String, dynamic> category) {
    setState(() {
      final i = selectedCategories.indexWhere((c) => c['id'] == category['id']);
      if (i >= 0) {
        selectedCategories.removeAt(i);
      } else {
        selectedCategories.add(category);
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
        if (type == 'category') _selectCategory(item);
      },
    );
  }

  void _showSealPopup() {
    PopupSeals.show(
      context: context,
      seals: dataController.seals,
      selectedSeals: selectedSeals,
      onSealStateChanged: (updated) {
        setState(() {
          selectedSeals = updated
              .where((s) => s['state'] != 'none')
              .map((s) => {'id': s['id'], 'name': s['name'], 'state': s['state']})
              .toList();
        });
        applyFilters();
      },
    );
  }

  void _onMarkerTap(BuildContext context, Map<String, dynamic> data) {
    final r = context.r;

    setState(() => activeMarker = data['id'].toString());
    InfoCardPopup.show(
      context: context,
      data: data,
      translations: widget.translations,
      allSeals: dataController.seals,
      onDismiss: () => setState(() => activeMarker = ''),

      bottomBarHeight: 0,
      extraBottomGap: 0.1,
      maxHeightFactorPhone: 0.36,
      maxHeightFactorLarge: 0.28,
    );
  }


  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to apply filters. Please try again later.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.r; // Responsive helper
    final markers = MarkerWidget.createMarkers(
      context: context,
      markerData: dataController.markerData,
      activeMarker: activeMarker,
      onMarkerTap: _onMarkerTap,
    );

    final topPad = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              key: widget.mapAreaKey,
              child: FlutterMap(
                mapController: mapController,
                options: const MapOptions(
                  initialCenter: LatLng(52.4009, 13.0591),
                  initialZoom: 13.0,
                ),
                children: [
                  buildBaseTileLayer(useLocalTiles: kUseLocalTiles),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),

          // Gradiente superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: r.rh(140),
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Switch Map/List
          Positioned(
            top: topPad,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTapList,
              child: ViewSwitchBar(
                onTapList: widget.onTapList,
                viewSwitchKey: widget.viewSwitchKey,
              ),
            ),
          ),

          // Chips de filtros
          Positioned(
            top: topPad + r.r(44),
            left: r.r(10),
            right: r.r(10),
            child: SelectedFiltersBar(
              selectedSeals: selectedSeals,
              selectedCategories: selectedCategories,
              onRemove: (item, type) {
                if (type == 'seal') _selectSeal(item);
                if (type == 'category') _selectCategory(item);
              },
            ),
          ),

          // Controles (zoom/filtro/sellos) con escala
          Positioned(
            top: topPad + r.r(86),
            right: r.r(10),
            child: Transform.scale(
              scale: (r.w <= 420) ? 0.86 : (r.w <= 520 ? 0.92 : 1.0),
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
          ),

          // Positioned(
          //   top: topPad + r.r(86),
          //   left: r.r(10),
          //   child: PointsCard(
          //     isAuthenticated: widget.isAuthenticated,
          //     points: dataController.points,
          //     totalPointsLabel: widget.translations['user']?['totalPoints'] ?? "Points",
          //   ),
          // ),
        ],
      ),
    );
  }
}
