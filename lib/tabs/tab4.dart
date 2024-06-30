import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../user_data_provider.dart';

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
  late TextEditingController _emailController;
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    _nameController = TextEditingController(text: userData.name);
    _emailController = TextEditingController(text: userData.email);
    _phoneController = TextEditingController(text: userData.phone);
  }

  void _toggleEdit(UserDataProvider userData) {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      userData.saveUserData(_nameController.text, _emailController.text, _phoneController.text);
    }
  }

  void _changePassword(BuildContext context) {
    // Aquí va la lógica para cambiar la contraseña
    // Puede ser una nueva pantalla o un modal, según tus necesidades
  }

  Future<void> _logout(UserDataProvider userData) async {
    await userData.logout();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginScreen(
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
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
                              userData.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${widget.translations['email'] ?? 'Correo electrónico'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            _isEditing
                                ? CupertinoTextField(
                              controller: _emailController,
                            )
                                : Text(
                              userData.email,
                              style: const TextStyle(fontSize: 18),
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
                              userData.phone,
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
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // URL de la imagen de perfil
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () => _toggleEdit(userData),
                      child: Text(
                        _isEditing
                            ? widget.translations['save'] ?? 'Guardar'
                            : widget.translations['modifyProfile'] ?? 'Modificar perfil',
                      ),
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
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      onPressed: () => _logout(userData),
                      child: Text(widget.translations['logout'] ?? 'Cerrar sesión'),
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
