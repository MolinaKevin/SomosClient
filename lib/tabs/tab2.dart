import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tab2 extends StatefulWidget {
  final Map<String, String> translations;

  const Tab2({super.key, required this.translations});

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  int _selectedSegment = 0;

  final List<Map<String, String>> _comercios = const [
    {
      'title': 'Comercio Ejemplo 1',
      'address': 'Calle Comercio 123',
      'phone': '+1 234 567 890',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Comercio Ejemplo 2',
      'address': 'Avenida Comercio 456',
      'phone': '+1 234 567 891',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Comercio Ejemplo 3',
      'address': 'Boulevard Comercio 789',
      'phone': '+1 234 567 892',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Comercio Ejemplo 4',
      'address': 'Plaza Comercio 101',
      'phone': '+1 234 567 893',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Comercio Ejemplo 5',
      'address': 'Calle Comercio 202',
      'phone': '+1 234 567 894',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  final List<Map<String, String>> _instituciones = const [
    {
      'title': 'Institución Ejemplo 1',
      'address': 'Calle Falsa 123',
      'phone': '+1 234 567 890',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 2',
      'address': 'Avenida Siempre Viva 456',
      'phone': '+1 234 567 891',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 3',
      'address': 'Boulevard de los Sueños 789',
      'phone': '+1 234 567 892',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 4',
      'address': 'Plaza de la Constitución 101',
      'phone': '+1 234 567 893',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Institución Ejemplo 5',
      'address': 'Calle de la Rosa 202',
      'phone': '+1 234 567 894',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  List<Map<String, String>> get _currentList {
    return _selectedSegment == 0 ? _comercios : _instituciones;
  }

  void _showFilterPopup(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['filterOptions'] ?? 'Opciones de Filtro'),
          message: Text('Este es un mensaje de prueba para el filtro.'),
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['close'] ?? 'Cerrar'),
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
                      0: Text(widget.translations['comercios'] ?? 'Comercios'),
                      1: Text(widget.translations['instituciones'] ?? 'Instituciones'),
                    },
                    onValueChanged: (int value) {
                      print("Selected Segment: $value"); // Add this line for debugging
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
                  child: Icon(CupertinoIcons.slider_horizontal_3),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView.builder(
              key: PageStorageKey<String>('listView$_selectedSegment'),
              itemCount: _currentList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _currentList[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      item['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['title']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.translations['address'] ?? 'Dirección'}: ${item['address']}'),
                        Text('${widget.translations['phone'] ?? 'Teléfono'}: ${item['phone']}'),
                      ],
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward),
                    onTap: () {
                      // Lógica para ir a la descripción (sin función actualmente)
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
