import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tab4 extends StatelessWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const Tab4({super.key, required this.translations, required this.onChangeLanguage});

  void _showModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(translations['information'] ?? 'Información'),
        message: Text(translations['thisIsTest'] ?? 'Esta es una prueba.'),
        cancelButton: CupertinoActionSheetAction(
          child: Text(translations['close'] ?? 'Cerrar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${translations['name'] ?? 'Nombre'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Juan Pérez',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['email'] ?? 'Correo electrónico'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'juan.perez@example.com',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['phone'] ?? 'Teléfono'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+1 234 567 8900',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${translations['points'] ?? 'Puntos'}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '25555',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showModal(context),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150'), // URL de la imagen de perfil
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        // Lógica para modificar el perfil (sin función actualmente)
                      },
                      child: Text(translations['modifyProfile'] ?? 'Modificar perfil'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('en'));
                      },
                      child: const Text('English'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('es'));
                      },
                      child: const Text('Español'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        onChangeLanguage(const Locale('de'));
                      },
                      child: const Text('Deutsch'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
