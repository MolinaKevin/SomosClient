import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tab2 extends StatelessWidget {
  final Map<String, String> translations;

  const Tab2({super.key, required this.translations});

  final List<Map<String, String>> _tarjetas = const [
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

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: ListView.builder(
            itemCount: _tarjetas.length,
            itemBuilder: (BuildContext context, int index) {
              final tarjeta = _tarjetas[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    tarjeta['image']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(tarjeta['title']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${translations['address']}: ${tarjeta['address']}'),
                      Text('${translations['phone']}: ${tarjeta['phone']}'),
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
        );
      },
    );
  }
}
