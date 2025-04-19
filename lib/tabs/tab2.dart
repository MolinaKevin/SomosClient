import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../mocking/mock_commerce_service.dart';
import '../mocking/mock_category_service.dart';
import '../mocking/mock_institution_service.dart';
import '../widgets/entity_list_item_widget.dart';
import '../widgets/filter_widget.dart';
import '../screens/entity_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> translations;

  const Tab2({Key? key, required this.translations}) : super(key: key);

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  int _selectedSegment = 0;
  bool _isLoading = true;
  final MockCommerceService commerceService = MockCommerceService();
  final MockInstitutionService institutionService = MockInstitutionService();
  final MockCategoryService categoryService = MockCategoryService();
  List<Map<String, dynamic>> _comercios = [];
  List<Map<String, dynamic>> _instituciones = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _showOnlyOpen = false;
  double? _selectedDistance;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      _fetchData();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || kIsWeb)) {
      print('Geolocation is not supported on this platform.');
      setState(() {
        _currentPosition = null;
      });
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error while fetching location: $e');
      setState(() {
        _currentPosition = null;
      });
    }
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    try {
      final commerceData = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
      final institutionData = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);

      final categoriesData = await categoryService.fetchCategories();

      Map<int, String> flattenCategoryHierarchy(List<Map<String, dynamic>> categories) {
        final Map<int, String> flattenedMap = {};
        void traverseCategories(List<dynamic> categories) {
          for (var category in categories) {
            if (category is Map<String, dynamic>) {
              final int id = category['id'];
              final String name = category['name'];
              flattenedMap[id] = name;
              if (category['children'] != null && category['children'] is List) {
                traverseCategories(category['children'] as List<dynamic>);
              }
            } else {
              print('Invalid category structure: $category');
            }
          }
        }
        traverseCategories(categories);
        return flattenedMap;
      }

      final categoriesMap = flattenCategoryHierarchy(
        categoriesData.whereType<Map<String, dynamic>>().toList(),
      );

      final allCategoryIds = commerceData.expand((commerce) => commerce['category_ids'] ?? []).toSet();
      final categoryNames = allCategoryIds.map((id) => categoriesMap[id] ?? 'Unknown').toSet();

      print('Raw categories from backend: $categoriesData');
      print('Flattened categories map: $categoriesMap');
      print('Unique category names from commerces: $categoryNames');

      setState(() {
        _categories = ['All', ...categoryNames];
        _comercios = commerceData.map((commerce) {
          double latitude = double.tryParse(commerce['latitude'] ?? '') ?? 0.0;
          double longitude = double.tryParse(commerce['longitude'] ?? '') ?? 0.0;

          double? distance;
          if (_currentPosition != null) {
            try {
              distance = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                latitude,
                longitude,
              );
            } catch (e) {
              distance = null;
            }
          }

          final commerceCategoryNames = (commerce['category_ids'] as List<dynamic>?)
              ?.map((id) => categoriesMap[id] ?? 'Unknown')
              .join(', ');

          return {
            'id': commerce['id'],
            'name': commerce['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
            'address': commerce['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
            'phone': commerce['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
            'latitude': latitude,
            'longitude': longitude,
            'is_open': commerce['is_open'] ?? false,
            'avatar_url': commerce['avatar_url'],
            'background_image': commerce['background_image'] ?? '',
            'category': commerceCategoryNames ?? 'Unknown',
            'distance': distance,
            'seals_with_state': commerce['seals_with_state'] ?? [],
          };
        }).toList();
        _instituciones = institutionData.map((institution) {
          double latitude = double.tryParse(institution['latitude'] ?? '') ?? 0.0;
          double longitude = double.tryParse(institution['longitude'] ?? '') ?? 0.0;

          double? distance;
          if (_currentPosition != null) {
            try {
              distance = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                latitude,
                longitude,
              );
            } catch (e) {
              distance = null;
            }
          }

          return {
            'id': institution['id'],
            'name': institution['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
            'address': institution['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
            'phone': institution['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
            'latitude': latitude,
            'longitude': longitude,
            'is_open': institution['is_open'] ?? false,
            'avatar_url': institution['avatar_url'],
            'background_image': institution['background_image'] ?? '',
            'category': institution['category'] ?? 'Unknown',
            'distance': distance,
          };
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _currentList {
    List<Map<String, dynamic>> list = _selectedSegment == 0 ? _comercios : _instituciones;

    return list.where((item) {
      bool matchesCategory = _selectedCategory == 'All' ||
          (item['category']?.split(', ').contains(_selectedCategory) ?? false);

      bool matchesOpenNow = !_showOnlyOpen || item['is_open'] == true;
      bool matchesDistance = _selectedDistance == null ||
          (item['distance'] != null && item['distance'] <= _selectedDistance!);

      return matchesCategory && matchesOpenNow && matchesDistance;
    }).toList();
  }


  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _showOnlyOpen = false;
      _selectedDistance = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: CupertinoSegmentedControl<int>(
                    children: {
                      0: Text(widget.translations['entities']?['comercios'] ?? 'Comercios'),
                      1: Text(widget.translations['entities']?['instituciones'] ?? 'Institutions'),
                    },
                    onValueChanged: (int value) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    },
                    groupValue: _selectedSegment,
                  ),
                ),
                const SizedBox(width: 10),
                FilterWidget(
                  translations: widget.translations,
                  availableCategories: _categories,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onDistanceSelected: (distance) {
                    setState(() {
                      _selectedDistance = distance;
                    });
                  },
                  onToggleOpenNow: (isOpen) {
                    setState(() {
                      _showOnlyOpen = isOpen;
                    });
                  },
                  onResetFilters: _resetFilters,
                ),
              ],
            ),
          ),
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : SafeArea(
            child: ListView.builder(
              key: PageStorageKey<String>('listView$_selectedSegment'),
              itemCount: _currentList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _currentList[index];

                return EntityListItemWidget(
                  entity: item,
                  translations: widget.translations,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => EntityDetailScreen(
                          title: item['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
                          address: item['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
                          phone: item['phone'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
                          imageUrl: item['avatar_url'] ?? '',
                          email: item['email'] ?? widget.translations['entities']?['noEmail'] ?? 'Email not available',
                          city: item['city'] ?? widget.translations['entities']?['noCity'] ?? 'City not available',
                          description: item['description'] ?? widget.translations['entities']?['noDescription'] ?? 'Description not available',
                          backgroundImage: item['background_image'] ?? '',
                          fotosUrls: item['fotos_urls'] != null && item['fotos_urls'] is List
                              ? List<String>.from(item['fotos_urls'].whereType<String>())
                              : [],
                          seals: item['seals_with_state'] != null
                              ? List<Map<String, dynamic>>.from(item['seals_with_state']).where(
                                (seal) => seal['state'] == 'partial' || seal['state'] == 'full',
                          ).toList()
                              : [],
                          translations: widget.translations,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
