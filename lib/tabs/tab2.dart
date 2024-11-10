import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/commerce_service.dart';
import '../services/institution_service.dart';
import '../screens/entity_detail_screen.dart';

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> translations;

  const Tab2({super.key, required this.translations});

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  int _selectedSegment = 0;
  bool _isLoading = true; // Indicador de carga
  final CommerceService commerceService = CommerceService();
  final InstitutionService institutionService = InstitutionService();
  List<Map<String, dynamic>> _comercios = [];
  List<Map<String, dynamic>> _instituciones = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    try {
      final commerceData = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
      final institutionData = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);

      setState(() {
        _comercios = commerceData.map((commerce) {
          return {
            'id': commerce['id'],
            'name': commerce['name'] ?? widget.translations['noDataAvailable'] ?? 'Nombre no disponible',
            'address': commerce['address'] ?? widget.translations['noDataAvailable'] ?? 'Dirección no disponible',
            'phone': commerce['phone_number'] ?? widget.translations['noDataAvailable'] ?? 'Teléfono no disponible',
            'latitude': double.tryParse(commerce['latitude'] ?? '') ?? 0.0,
            'longitude': double.tryParse(commerce['longitude'] ?? '') ?? 0.0,
            'is_open': commerce['is_open'] ?? false,
            'avatar': commerce['avatar'],
            'avatar_url': commerce['avatar_url'],
            'background_image': commerce['background_image'] ?? '',
            'fotos_urls': (commerce['fotos_urls'] != null && commerce['fotos_urls'] is List)
                ? List<String>.from(commerce['fotos_urls'].where((url) => url is String))
                : [], // Asegurarse de que es una lista de Strings
          };
        }).toList();

        _instituciones = institutionData.map((institution) {
          return {
            'id': institution['id'],
            'name': institution['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Nombre no disponible',
            'address': institution['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Dirección no disponible',
            'phone': institution['phone_number'] ?? widget.translations['entities']?['noPhone'] ?? 'Teléfono no disponible',
            'email': institution['email'] ?? widget.translations['entities']?['noEmail'] ?? 'Correo no disponible',
            'city': institution['city'] ?? widget.translations['entities']?['noCity'] ?? 'Ciudad no disponible',
            'description': institution['description'] ?? widget.translations['entities']?['noDescription'] ?? 'Descripción no disponible',
            'latitude': double.tryParse(institution['latitude'] ?? '') ?? 0.0,
            'longitude': double.tryParse(institution['longitude'] ?? '') ?? 0.0,
            'is_open': institution['is_open'] ?? false,
            'avatar': institution['avatar'],
            'avatar_url': institution['avatar_url'],
            'background_image': institution['background_image'] ?? '',
            'fotos_urls': (institution['fotos_urls'] != null && institution['fotos_urls'] is List)
                ? List<String>.from(institution['fotos_urls'].where((url) => url is String))
                : [], // Asegurarse de que es una lista de Strings
          };
        }).toList();
        _isLoading = false; // Detenemos el indicador de carga
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false; // Detenemos el indicador de carga en caso de error
      });
    }
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
                        widget.translations['entities']?['instituciones'] ?? 'Instituciones',
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
                SizedBox(width: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _showFilterPopup(context);
                  },
                  child: Icon(CupertinoIcons.search),
                ),
              ],
            ),
          ),
          child: _isLoading
              ? Center(child: CupertinoActivityIndicator()) // Mostrar un indicador de carga mientras los datos están cargando
              : SafeArea(
            child: ListView.builder(
              key: PageStorageKey<String>('listView$_selectedSegment'),
              itemCount: _currentList.length,
              itemBuilder: (BuildContext context, int index) {
                if (index >= _currentList.length) {
                  return SizedBox.shrink();
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
                        : Icon(CupertinoIcons.photo, size: 50),
                    title: Text(
                      item['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Nombre no disponible',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.translations['entities']?['address'] ?? 'Dirección'}: ${item['address']}',
                        ),
                        Text(
                          '${widget.translations['entities']?['phone'] ?? 'Teléfono'}: ${item['phone']}',
                        ),
                      ],
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => EntityDetailScreen(
                            title: item['name'] ?? widget.translations['common']?['noDataAvailable'] ?? 'Nombre no disponible',
                            address: item['address'] ?? widget.translations['entities']?['noAddress'] ?? 'Dirección no disponible',
                            phone: item['phone'] ?? widget.translations['entities']?['noPhone'] ?? 'Teléfono no disponible',
                            imageUrl: item['avatar_url'] ?? '',
                            email: item['email'] ?? widget.translations['entities']?['noEmail'] ?? 'Correo no disponible',
                            city: item['city'] ?? widget.translations['entities']?['noCity'] ?? 'Ciudad no disponible',
                            description: item['description'] ?? widget.translations['entities']?['noDescription'] ?? 'Descripción no disponible',
                            backgroundImage: item['background_image'] ?? '',
                            fotosUrls: item['fotos_urls'] != null && item['fotos_urls'] is List
                                ? List<String>.from(item['fotos_urls'].where((url) => url is String))
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

  List<Map<String, dynamic>> get _currentList {
    return _selectedSegment == 0 ? _comercios : _instituciones;
  }

  void _showFilterPopup(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filter']?['options'] ?? 'Opciones de Filtro'),
          message: Column(
            children: [
              CupertinoActionSheetAction(
                child: Text(widget.translations['filter']?['category'] ?? 'Filtrar por categoría'),
                onPressed: () {
                  _showCategoryFilter(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(widget.translations['filter']?['location'] ?? 'Filtrar por ubicación'),
                onPressed: () {
                  _showLocationFilter(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(widget.translations['filter']?['openNow'] ?? 'Solo mostrar abiertos'),
                onPressed: () {
                  _applyOpenNowFilter();
                  Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(widget.translations['filter']?['rating'] ?? 'Filtrar por puntuación'),
                onPressed: () {
                  _showRatingFilter(context);
                },
              ),
            ],
          ),
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']?['close'] ?? 'Cerrar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _applyOpenNowFilter() {
    setState(() {
      if (_selectedSegment == 0) {
        _comercios = _comercios.where((commerce) => commerce['is_open'] == true).toList();
      } else {
        _instituciones = _instituciones.where((institution) => institution['is_open'] == true).toList();
      }
    });
  }

  void _showCategoryFilter(BuildContext context) {
    // Lógica para mostrar y aplicar el filtro por categoría
  }

  void _showLocationFilter(BuildContext context) {
    // Lógica para filtrar por ubicación
  }

  void _showRatingFilter(BuildContext context) {
    // Lógica para filtrar por puntuación
  }
}
