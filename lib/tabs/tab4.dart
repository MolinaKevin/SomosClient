import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tab4 extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;

  const Tab4({
    super.key,
    required this.translations,
    required this.onChangeLanguage,
    required this.currentLocale,
  });

  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Juan Pérez');
    _phoneController = TextEditingController(text: '+1 234 567 8900');
    _selectedLocale = widget.currentLocale;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      // Save changes
      print('Name: ${_nameController.text}');
      print('Phone: ${_phoneController.text}');
      print('Language: ${_selectedLocale.languageCode}');
      // Aquí puedes agregar la lógica para guardar la información
    }
  }

  void _changePassword(BuildContext context) {
    // Aquí va la lógica para cambiar la contraseña
    // Puede ser una nueva pantalla o un modal, según tus necesidades
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
                              '${widget.translations['name'] ?? 'Nombre'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            _isEditing
                                ? CupertinoTextField(
                              controller: _nameController,
                            )
                                : Text(
                              _nameController.text,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${widget.translations['email'] ?? 'Correo electrónico'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'juan.perez@example.com',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${widget.translations['phone'] ?? 'Teléfono'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            _isEditing
                                ? CupertinoTextField(
                              controller: _phoneController,
                            )
                                : Text(
                              _phoneController.text,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${widget.translations['language'] ?? 'Idioma'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            _isEditing
                                ? CupertinoButton(
                              onPressed: () => _showLanguageSelector(context),
                              child: Text(_selectedLocale.languageCode),
                            )
                                : Text(
                              _selectedLocale.languageCode,
                              style: const TextStyle(fontSize: 18),
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
                      onPressed: _toggleEdit,
                      child: Text(_isEditing
                          ? widget.translations['save'] ?? 'Guardar'
                          : widget.translations['modifyProfile'] ?? 'Modificar perfil'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () => _changePassword(context),
                      child: Text(widget.translations['changePassword'] ?? 'Cambiar Contraseña'),
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

  void _showModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(widget.translations['information'] ?? 'Información'),
        message: Text(widget.translations['thisIsTest'] ?? 'Esta es una prueba.'),
        cancelButton: CupertinoActionSheetAction(
          child: Text(widget.translations['close'] ?? 'Cerrar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['selectLanguage'] ?? 'Seleccionar idioma'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('English'),
              onPressed: () {
                setState(() {
                  _selectedLocale = const Locale('en');
                });
                widget.onChangeLanguage(_selectedLocale);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Español'),
              onPressed: () {
                setState(() {
                  _selectedLocale = const Locale('es');
                });
                widget.onChangeLanguage(_selectedLocale);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Deutsch'),
              onPressed: () {
                setState(() {
                  _selectedLocale = const Locale('de');
                });
                widget.onChangeLanguage(_selectedLocale);
                Navigator.pop(context);
              },
            ),
          ],
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
}
