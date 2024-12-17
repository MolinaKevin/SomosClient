import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/commerce_service.dart';
import '../services/institution_service.dart';
import '../screens/entity_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../widgets/seal_icon_widget.dart';

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> translations;

  const Tab2({Key? key, required this.translations}) : super(key: key);

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  int _selectedSegment = 0;
  bool _isLoading = true;
  final CommerceService commerceService = CommerceService();
  final InstitutionService institutionService = InstitutionService();
  List<Map<String, dynamic>> _comercios = [];
  List<Map<String, dynamic>> _instituciones = [];

  String _selectedCategory = 'All';
  double _selectedRating = 0.0;
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
    } on MissingPluginException catch (e) {
      print('Geolocation plugin not available: $e');
      setState(() {
        _currentPosition = null;
      });
    } catch (e) {
      print('An error occurred while fetching location: $e');
      setState(() {
        _currentPosition = null;
      });
    }
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    try {
      final commerceData = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
      final institutionData = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);

      setState(() {
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
            } on MissingPluginException catch (e) {
              print('Geolocation plugin not available: $e');
              distance = null;
            } catch (e) {
              print('Error calculating distance: $e');
              distance = null;
            }
          }

          return {
            'id': commerce['id'],
            'name': commerce['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
            'address': commerce['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
            'phone': commerce['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
            'latitude': latitude,
            'longitude': longitude,
            'is_open': commerce['is_open'] ?? false,
            'avatar': commerce['avatar'],
            'avatar_url': commerce['avatar_url'],
            'background_image': commerce['background_image'] ?? '',
            'fotos_urls': (commerce['fotos_urls'] != null && commerce['fotos_urls'] is List)
                ? List<String>.from(commerce['fotos_urls'].whereType<String>())
                : [],
            'category': commerce['category'] ?? 'Unknown',
            'location': commerce['location'] ?? 'Unknown',
            'rating': double.tryParse(commerce['rating']?.toString() ?? '') ?? 0.0,
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
            } on MissingPluginException catch (e) {
              print('Geolocation plugin not available: $e');
              distance = null;
            } catch (e) {
              print('Error calculating distance: $e');
              distance = null;
            }
          }

          return {
            'id': institution['id'],
            'name': institution['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
            'address': institution['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
            'phone': institution['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
            'email': institution['email'] ?? widget.translations['entities']?['noEmail'] ?? 'Email not available',
            'city': institution['city'] ?? widget.translations['entities']?['noCity'] ?? 'City not available',
            'description': institution['description'] ?? widget.translations['entities']?['noDescription'] ?? 'Description not available',
            'latitude': latitude,
            'longitude': longitude,
            'is_open': institution['is_open'] ?? false,
            'avatar': institution['avatar'],
            'avatar_url': institution['avatar_url'],
            'background_image': institution['background_image'] ?? '',
            'fotos_urls': (institution['fotos_urls'] != null && institution['fotos_urls'] is List)
                ? List<String>.from(institution['fotos_urls'].whereType<String>())
                : [],
            'category': institution['category'] ?? 'Unknown',
            'location': institution['location'] ?? 'Unknown',
            'rating': double.tryParse(institution['rating']?.toString() ?? '') ?? 0.0,
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
      bool matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      bool matchesRating = _selectedRating == 0.0 || (item['rating'] != null && item['rating'] >= _selectedRating);
      bool matchesOpenNow = !_showOnlyOpen || item['is_open'] == true;
      bool matchesDistance = _selectedDistance == null ||
          (item['distance'] != null && item['distance'] <= _selectedDistance!);

      return matchesCategory && matchesRating && matchesOpenNow && matchesDistance;
    }).toList();
  }

  void _showFilterPopup(BuildContext context) {
    bool isLocationSupported = Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || kIsWeb;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filter']?['options'] ?? 'Filter Options'),
          actions: [
            CupertinoActionSheetAction(
              child: Text(widget.translations['filter']?['category'] ?? 'Filter by category'),
              onPressed: () {
                Navigator.pop(context);
                _showCategoryFilter(context);
              },
            ),
            if (isLocationSupported)
              CupertinoActionSheetAction(
                child: Text(widget.translations['filter']?['location'] ?? 'Filter by location'),
                onPressed: () {
                  Navigator.pop(context);
                  _showDistanceFilter(context);
                },
              ),
            CupertinoActionSheetAction(
              child: Text(widget.translations['filter']?['openNow'] ?? 'Show only open'),
              onPressed: () {
                setState(() {
                  _showOnlyOpen = !_showOnlyOpen;
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(widget.translations['filter']?['rating'] ?? 'Filter by rating'),
              onPressed: () {
                Navigator.pop(context);
                _showRatingFilter(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(widget.translations['filter']?['resetFilters'] ?? 'Reset Filters'),
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _selectedRating = 0.0;
                  _showOnlyOpen = false;
                  _selectedDistance = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']?['close'] ?? 'Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showCategoryFilter(BuildContext context) {
    List<String> categories = ['All'];

    List<Map<String, dynamic>> list = _selectedSegment == 0 ? _comercios : _instituciones;
    categories.addAll(
      list.map((item) => item['category']).whereType<String>().toSet(),
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filter']?['category'] ?? 'Filter by category'),
          actions: categories.map((category) {
            return CupertinoActionSheetAction(
              child: Text(category),
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']?['cancel'] ?? 'Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDistanceFilter(BuildContext context) {
    List<double?> distancesInMeters = [null, 2000, 5000, 10000, 25000, 50000, 100000, 200000];

    List<String> distanceOptions = [
      widget.translations['filter']?['location.all'] ?? 'All locations',
      '+2km',
      '+5km',
      '+10km',
      '+25km',
      '+50km',
      '+100km',
      '+200km',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filter']?['location'] ?? 'Filter by location'),
          actions: List.generate(distancesInMeters.length, (index) {
            return CupertinoActionSheetAction(
              child: Text(distanceOptions[index]),
              onPressed: () {
                setState(() {
                  _selectedDistance = distancesInMeters[index];
                });
                Navigator.pop(context);
              },
            );
          }),
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']?['cancel'] ?? 'Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showRatingFilter(BuildContext context) {
    List<double> ratings = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filter']?['rating'] ?? 'Filter by rating'),
          actions: ratings.map((rating) {
            String ratingText = rating == 0.0
                ? (widget.translations['filter']?['rating.all'] ?? 'All Ratings')
                : '$rating+';
            return CupertinoActionSheetAction(
              child: Text(ratingText),
              onPressed: () {
                setState(() {
                  _selectedRating = rating;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']?['cancel'] ?? 'Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
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
                      0: Text(
                        widget.translations['entities']?['comercios'] ?? 'Comercios',
                      ),
                      1: Text(
                        widget.translations['entities']?['instituciones'] ?? 'Institutions',
                      ),
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
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _showFilterPopup(context);
                  },
                  child: const Icon(CupertinoIcons.search),
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
                if (index >= _currentList.length) {
                  return const SizedBox.shrink();
                }
                final item = _currentList[index];

                return Card(
                  child: ListTile(
                    leading: item['avatar_url'] != null && item['avatar_url'].isNotEmpty
                        ? Image.network(
                      item['avatar_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const Icon(CupertinoIcons.photo, size: 50),
                    title: Text(
                      item['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.translations['entities']?['address'] ?? 'Address'}: ${item['address']}',
                        ),
                        Text(
                          '${widget.translations['entities']?['phone'] ?? 'Phone'}: ${item['phone']}',
                        ),
                        Text(
                          '${widget.translations['entities']?['category'] ?? 'Category'}: ${item['category']}',
                        ),
                        Text(
                          '${widget.translations['entities']?['rating'] ?? 'Rating'}: ${item['rating'].toString()}',
                        ),
                        if (item['distance'] != null && _currentPosition != null)
                          Text(
                            '${(item['distance'] / 1000).toStringAsFixed(2)} ${widget.translations['filter']?['location.kilometers'] ?? 'km'}',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item['seals_with_state'] != null &&
                            (item['seals_with_state'] as List).isNotEmpty)
                          ...List<Map<String, dynamic>>.from(item['seals_with_state'])
                              .where((seal) => seal['state'] == 'partial' || seal['state'] == 'full')
                              .take(3)
                              .map((seal) {
                            print('el itemnazo: ${item}');
                            print('Seal encontrado: $seal');
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: SealIconWidget(seal: seal),
                            );
                          })
                        else ...[
                          (() {
                            print('No hay seals_with_state o no cumplen las condiciones');
                            print('el itemnazo: ${item}');
                            return const SizedBox();
                          })(),
                        ],


                        const Icon(CupertinoIcons.chevron_forward),
                      ],
                    ),


                    onTap: () {
                      print('Navegando a detalles de: ${item['name']}');
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
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
