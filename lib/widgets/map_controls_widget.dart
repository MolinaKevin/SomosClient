import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapControlsWidget extends StatefulWidget {
  final MapController mapController;
  final Map<String, dynamic> translations;
  final VoidCallback showFilterPopup;
  final VoidCallback showSealPopup;

  const MapControlsWidget({
    Key? key,
    required this.mapController,
    required this.translations,
    required this.showFilterPopup,
    required this.showSealPopup,
  }) : super(key: key);

  @override
  _MapControlsWidgetState createState() => _MapControlsWidgetState();
}

class _MapControlsWidgetState extends State<MapControlsWidget> {
  bool _isSearching = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchSuggestions = [];

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
        print('Error fetching search suggestions');
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
    return Row(
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
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.green),
                onPressed: () {
                  widget.mapController.move(
                      widget.mapController.center, widget.mapController.zoom + 1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.red),
                onPressed: () {
                  widget.mapController.move(
                      widget.mapController.center, widget.mapController.zoom - 1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt, color: Colors.blue),
                onPressed: widget.showFilterPopup,
              ),
              IconButton(
                icon: const Icon(Icons.circle, color: Colors.yellow),
                onPressed: widget.showSealPopup,
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
                                hintText: widget.translations['entities']['search'] ??
                                    'Search...',
                                border: InputBorder.none,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
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
                              widget.mapController.move(LatLng(lat, lon), 15.0);
                              _toggleSearch();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
