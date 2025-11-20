import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import '../services/commerce_service.dart';
import '../services/category_service.dart';
import '../services/institution_service.dart';
import '../screens/entity_detail_screen.dart';
import '../widgets/seal_icon_widget.dart';

class TabList extends StatefulWidget {
  final Map<String, dynamic> translations;

  const TabList({Key? key, required this.translations}) : super(key: key);

  @override
  _TabListState createState() => _TabListState();
}

class _TabListState extends State<TabList> {
  static const _cream = Color(0xFFFFF5E6);
  static const _green = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

  int _selectedSegment = 0;
  bool _isLoading = true;

  final CommerceService commerceService = CommerceService();
  final InstitutionService institutionService = InstitutionService();
  final CategoryService categoryService = CategoryService();

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
    _getCurrentLocation().whenComplete(_fetchData);
  }

  Future<void> _getCurrentLocation() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || kIsWeb)) {
      debugPrint('Geolocation not supported on this platform.');
      _currentPosition = null;
      return;
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint('Geolocation error: $e');
      _currentPosition = null;
    }
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> commerceData = const [];
    List<Map<String, dynamic>> institutionData = const [];
    List<Map<String, dynamic>> categoriesData = const [];

    try {
      commerceData = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint('Error fetching commerces: $e');
      commerceData = const [];
    }

    try {
      institutionData = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint('Error fetching institutions: $e');
      institutionData = const [];
    }

    try {
      categoriesData = await categoryService.fetchCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      categoriesData = const [];
    }

    final categoriesMap = _flattenCategoryHierarchy(categoriesData);

    final allCategoryIds = commerceData
        .expand((c) => (c['category_ids'] as List?)?.cast<int>() ?? const <int>[])
        .toSet();
    final categoryNames = allCategoryIds.map((id) => categoriesMap[id] ?? 'Unknown').toSet();

    final currentPos = _currentPosition;
    final mappedCommerces = commerceData.map((c) {
      final lat = _toDouble(c['latitude']);
      final lng = _toDouble(c['longitude']);

      double? distance;
      if (currentPos != null && lat != null && lng != null) {
        try {
          distance = Geolocator.distanceBetween(currentPos.latitude, currentPos.longitude, lat, lng);
        } catch (_) {}
      }

      final commerceCategoryNames = ((c['category_ids'] as List?)?.cast<int>() ?? const <int>[])
          .map((id) => categoriesMap[id] ?? 'Unknown')
          .join(', ');

      return {
        'id': c['id'],
        'name': c['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
        'address': c['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
        'phone': c['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
        'latitude': lat ?? 0.0,
        'longitude': lng ?? 0.0,
        'is_open': c['is_open'] ?? false,
        'avatar_url': c['avatar_url'],
        'background_image': c['background_image'] ?? '',
        'category': commerceCategoryNames.isEmpty ? 'Unknown' : commerceCategoryNames,
        'distance': distance,
        'seals_with_state': (c['seals_with_state'] as List?) ?? const [],
        'email': c['email'],
        'city': c['city'],
        'description': c['description'],
        'fotos_urls': (c['fotos_urls'] as List?) ?? const [],
      };
    }).toList();

    final mappedInstitutions = institutionData.map((i) {
      final lat = _toDouble(i['latitude']);
      final lng = _toDouble(i['longitude']);

      double? distance;
      if (currentPos != null && lat != null && lng != null) {
        try {
          distance = Geolocator.distanceBetween(currentPos.latitude, currentPos.longitude, lat, lng);
        } catch (_) {}
      }

      return {
        'id': i['id'],
        'name': i['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Not available',
        'address': i['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Address not available',
        'phone': i['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Phone not available',
        'latitude': lat ?? 0.0,
        'longitude': lng ?? 0.0,
        'is_open': i['is_open'] ?? false,
        'avatar_url': i['avatar_url'],
        'background_image': i['background_image'] ?? '',
        'category': i['category'] ?? 'Unknown',
        'distance': distance,
        'email': i['email'],
        'city': i['city'],
        'description': i['description'],
        'fotos_urls': (i['fotos_urls'] as List?) ?? const [],
        'seals_with_state': const [],
      };
    }).toList();

    setState(() {
      _categories = ['All', ...categoryNames];
      _comercios = mappedCommerces;
      _instituciones = mappedInstitutions;
      _isLoading = false;
    });
  }

  Map<int, String> _flattenCategoryHierarchy(List<Map<String, dynamic>> categories) {
    final Map<int, String> out = {};
    void walk(List<dynamic> nodes) {
      for (final n in nodes) {
        if (n is Map<String, dynamic>) {
          final id = n['id'];
          final name = (n['name'] ?? '').toString();
          if (id is int) out[id] = name;
          final children = n['children'];
          if (children is List) walk(children);
        }
      }
    }
    walk(categories);
    return out;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  List<Map<String, dynamic>> get _currentList {
    final baseList = _selectedSegment == 0 ? _comercios : _instituciones;

    return baseList.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          (item['category']?.split(', ').contains(_selectedCategory) ?? false);

      final matchesOpenNow = !_showOnlyOpen || item['is_open'] == true;

      final matchesDistance = _selectedDistance == null ||
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
    final commercesLabel = widget.translations['entities']?['comercios'] ?? 'Commerces';
    final institutionsLabel = widget.translations['entities']?['instituciones'] ?? 'Institutions';

    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: _cream.withOpacity(.96),
            border: const Border(bottom: BorderSide(color: Colors.transparent)),
            middle: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: _PillTabs(
                  leftText: commercesLabel,
                  rightText: institutionsLabel,
                  selectedIndex: _selectedSegment,
                  onChanged: (i) => setState(() => _selectedSegment = i),
                ),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: _FilterPill(
                label: widget.translations['filters']?['filter'] ?? 'Filtrar',
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => _FiltersBottomSheet(
                      translations: widget.translations,
                      availableCategories: _categories,
                      selectedCategory: _selectedCategory,
                      selectedDistance: _selectedDistance,
                      showOnlyOpen: _showOnlyOpen,
                      onCategorySelected: (category) => setState(() => _selectedCategory = category),
                      onDistanceSelected: (distance) => setState(() => _selectedDistance = distance),
                      onToggleOpenNow: (isOpen) => setState(() => _showOnlyOpen = isOpen),
                      onResetFilters: () {
                        _resetFilters();
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : SafeArea(
            child: ListView.builder(
              key: PageStorageKey<String>('listView$_selectedSegment'),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                final item = _currentList[index];
                return _EntityListCard(
                  item: item,
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
                          fotosUrls: (item['fotos_urls'] as List?)?.whereType<String>().toList() ?? const [],
                          seals: (item['seals_with_state'] as List?)
                              ?.where((s) => s is Map && (s['state'] == 'partial' || s['state'] == 'full'))
                              .cast<Map<String, dynamic>>()
                              .toList() ??
                              const [],
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

class _PillTabs extends StatelessWidget {
  static const _cream = Color(0xFFFFF5E6);
  static const _green = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

  final String leftText;
  final String rightText;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PillTabs({
    Key? key,
    required this.leftText,
    required this.rightText,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;

    Widget buildBtn(String text, bool active, VoidCallback onTap) {
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _green : _cream,
            borderRadius: BorderRadius.circular(radius),
            border: active ? null : Border.all(color: _greenSoft.withOpacity(.25), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: active ? Colors.white : _greenSoft,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildBtn(leftText, selectedIndex == 0, () => onChanged(0)),
        const SizedBox(width: 6),
        buildBtn(rightText, selectedIndex == 1, () => onChanged(1)),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  static const _green = Color(0xFF103D1B);

  final String label;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityListCard extends StatelessWidget {
  static const _cream = Color(0xFFFFF5E6);

  final Map<String, dynamic> item;
  final Map<String, dynamic> translations;
  final VoidCallback onTap;

  const _EntityListCard({
    Key? key,
    required this.item,
    required this.translations,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasSeals = (item['seals_with_state'] as List?)?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _cream,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF103D1B),
                  backgroundImage: (item['avatar_url'] != null && item['avatar_url'].toString().isNotEmpty)
                      ? NetworkImage(item['avatar_url'])
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item['is_open'] == true ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['is_open'] == true
                                  ? (translations['entities']?['open'] ?? 'Open')
                                  : (translations['entities']?['closed'] ?? 'Closed'),
                              style: TextStyle(
                                fontSize: 13,
                                color: item['is_open'] == true ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (hasSeals) const SizedBox(width: 8),
                          if (hasSeals)
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List<Map<String, dynamic>>.from(item['seals_with_state'])
                                        .where((s) => s['state'] == 'partial' || s['state'] == 'full')
                                        .map(
                                          (s) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: SealIconWidget(
                                          seal: {'id': s['id'], 'state': s['state']},
                                          size: 28,
                                        ),
                                      ),
                                    )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name'] ?? translations['common']?['noDataAvailable'] ?? 'Not available',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if ((item['category'] ?? '').toString().isNotEmpty)
                        Text(
                          item['category'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      if ((item['address'] ?? '').toString().isNotEmpty)
                        Text(
                          item['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final Map<String, dynamic> translations;
  final List<String> availableCategories;
  final String selectedCategory;
  final double? selectedDistance;
  final bool showOnlyOpen;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<double?> onDistanceSelected;
  final ValueChanged<bool> onToggleOpenNow;
  final VoidCallback onResetFilters;

  const _FiltersBottomSheet({
    required this.translations,
    required this.availableCategories,
    required this.selectedCategory,
    required this.selectedDistance,
    required this.showOnlyOpen,
    required this.onCategorySelected,
    required this.onDistanceSelected,
    required this.onToggleOpenNow,
    required this.onResetFilters,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late String _cat;
  double? _dist;
  late bool _open;

  @override
  void initState() {
    super.initState();
    _cat = widget.selectedCategory;
    _dist = widget.selectedDistance;
    _open = widget.showOnlyOpen;
  }

  String _kmLabel(double? meters) {
    if (meters == null) return widget.translations['filters']?['noLimit'] ?? 'Sin límite';
    final km = (meters / 1000).clamp(0, 9999).toStringAsFixed(1).replaceAll('.0', '');
    return '$km km';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translations;
    final media = MediaQuery.of(context);
    final size = media.size;
    final isPhone = size.shortestSide < 600;
    final maxHeight = size.height * (isPhone ? 0.40 : 0.32);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t['filters']?['title'] ?? 'Filtros',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            t['common']?['close'] ?? 'Cerrar',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['filters']?['category'] ?? 'Categoría',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.availableCategories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final c = widget.availableCategories[i];
                                final active = c == _cat;
                                return GestureDetector(
                                  onTap: () => setState(() => _cat = c),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: active ? const Color(0xFF103D1B) : const Color(0xFFFFF5E6),
                                      borderRadius: BorderRadius.circular(18),
                                      border: active
                                          ? null
                                          : Border.all(
                                        color: const Color(0xFF2F5E3B).withOpacity(.25),
                                      ),
                                      boxShadow: active
                                          ? const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        )
                                      ]
                                          : const [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      c,
                                      style: TextStyle(
                                        color: active ? Colors.white : const Color(0xFF2F5E3B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t['filters']?['distance'] ?? 'Distancia',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CupertinoSwitch(
                                value: _dist != null,
                                onChanged: (on) => setState(() => _dist = on ? (_dist ?? 1000) : null),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _kmLabel(_dist),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          if (_dist != null) ...[
                            const SizedBox(height: 8),
                            CupertinoSlider(
                              min: 500,
                              max: 20000,
                              value: _dist!.clamp(500, 20000),
                              onChanged: (v) => setState(() => _dist = v),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t['filters']?['openNow'] ?? 'Abierto ahora',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              CupertinoSwitch(
                                value: _open,
                                onChanged: (v) => setState(() => _open = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    widget.onCategorySelected(_cat);
                                    widget.onDistanceSelected(_dist);
                                    widget.onToggleOpenNow(_open);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF103D1B),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      t['filters']?['apply'] ?? 'Aplicar',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: widget.onResetFilters,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFF2F5E3B).withOpacity(.25),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      t['filters']?['reset'] ?? 'Resetear',
                                      style: const TextStyle(
                                        color: Color(0xFF103D1B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
