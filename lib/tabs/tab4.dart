import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importa el paquete image_picker
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../providers/user_data_provider.dart';

class Tab4 extends StatefulWidget {
  final Map<String, dynamic> translations;
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
  bool _avatarUpdated = false; // Flag para saber si se ha cambiado el avatar
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passController;
  late TextEditingController _referrerPassController;
  late Locale _selectedLocale;
  File? _image; // Archivo de imagen seleccionado

  final ImagePicker _picker = ImagePicker(); // Instancia del ImagePicker

  @override
  void initState() {
    super.initState();

    // Inicializa _selectedLocale con el valor del idioma en userData
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    _selectedLocale = Locale(userData.language ?? 'en'); // Si no hay idioma, asigna 'en' por defecto.

    // Inicializar los controladores con los valores de userData
    _nameController = TextEditingController(text: userData.name != 'Nombre no disponible' ? userData.name : '');
    _emailController = TextEditingController(text: userData.email != 'Email no disponible' ? userData.email : '');
    _phoneController = TextEditingController(text: userData.phone != 'Teléfono no disponible' ? userData.phone : '');
    _passController = TextEditingController(text: userData.pass != 'No disponible' ? userData.pass : '');
    _referrerPassController = TextEditingController(text: userData.referrerPass != 'No disponible' ? userData.referrerPass : '');

    print('User data initialized: name = ${userData.name}, email = ${userData.email}, phone = ${userData.phone}, language = ${userData.language}, pass = ${userData.pass}, referrerPass = ${userData.referrerPass}');
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Guarda la imagen seleccionada
        _avatarUpdated = true; // Marca que el avatar ha sido actualizado
        _isEditing = true; // Activa el modo de edición automáticamente
      });
      _showSuccessPopup(); // Muestra el popup de éxito
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Guarda la imagen tomada con la cámara
        _avatarUpdated = true; // Marca que el avatar ha sido actualizado
        _isEditing = true; // Activa el modo de edición automáticamente
      });
      _showSuccessPopup(); // Muestra el popup de éxito
    }
  }

  Future<void> _uploadAvatar(UserDataProvider userData) async {
    if (_avatarUpdated && _image != null) {
      // Si se cambió el avatar, subimos la nueva imagen al servidor
      await userData.uploadAvatar(_image!);
      _avatarUpdated = false; // Reiniciar el flag después de subir la imagen
    }
  }

  void _showSuccessPopup() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(widget.translations['success'] ?? 'Éxito'),
          content: Text(widget.translations['imageUploaded'] ?? 'La imagen se ha cargado exitosamente.'),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.translations['ok'] ?? 'Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el popup
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleEdit(UserDataProvider userData) {
    setState(() {
      _isEditing = !_isEditing;
      print('_isEditing toggled: $_isEditing');
    });

    if (!_isEditing) {
      // Almacenar los datos solo cuando se haya completado la edición
      print('Saving user data: name = ${_nameController.text}, email = ${_emailController.text}, phone = ${_phoneController.text}, language = ${_selectedLocale.languageCode}, pass = ${_passController.text}, referrerPass = ${_referrerPassController.text}');

      // Usar el valor actual de userData si los campos están vacíos
      final updatedName = _nameController.text.isNotEmpty ? _nameController.text : userData.name;
      final updatedEmail = _emailController.text.isNotEmpty ? _emailController.text : userData.email;
      final updatedPhone = _phoneController.text.isNotEmpty ? _phoneController.text : userData.phone;
      final updatedPass = _passController.text.isNotEmpty ? _passController.text : userData.pass;
      final updatedReferrerPass = _referrerPassController.text.isNotEmpty ? _referrerPassController.text : userData.referrerPass;

      // Guarda los datos del usuario
      userData.saveUserData(
        updatedName,
        updatedEmail,
        updatedPhone,
        _selectedLocale.languageCode, // Envía el código de idioma seleccionado
        updatedPass,
        updatedReferrerPass,
      );

      // Subir el nuevo avatar si ha sido actualizado
      _uploadAvatar(userData);
    }
  }

  void _changePassword(BuildContext context) {
    print('Change password pressed');
    // Lógica para cambiar la contraseña
  }

  Future<void> _logout(UserDataProvider userData) async {
    print('Logout pressed');
    await userData.logout();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginScreen(
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
        translations: widget.translations, // Asegúrate de pasar las traducciones adecuadas
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    print('Building Tab4 screen');

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
                              placeholder: userData.name, // Mostrar el nombre actual como placeholder
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
                              placeholder: userData.email, // Mostrar el email actual como placeholder
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
                              placeholder: userData.phone, // Mostrar el teléfono actual como placeholder
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
                            const SizedBox(height: 20),
                            // Somos Pass no editable
                            Text(
                              '${widget.translations['pass'] ?? 'Somos Pass'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userData.pass ?? widget.translations['noDataAvailable'] ?? 'No disponible',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),

                            // Referrer Pass no editable
                            Text(
                              '${widget.translations['referrer_pass'] ?? 'Pass de referido'}:',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userData.referrerPass ?? widget.translations['noDataAvailable'] ?? 'No disponible',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showAvatarOptions(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _image != null
                              ? FileImage(_image!) // Si hay una imagen seleccionada localmente, la muestra
                              : (userData.profilePhotoUrl.isNotEmpty
                              ? NetworkImage(userData.profilePhotoUrl) // Si no hay imagen seleccionada, muestra la que viene del servidor
                              : const NetworkImage('https://via.placeholder.com/150')) as ImageProvider, // Placeholder en caso de que no haya avatar
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

  // Función para mostrar opciones de subir avatar desde galería o cámara
  void _showAvatarOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(widget.translations['avatarOptions'] ?? 'Opciones de Avatar'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(widget.translations['uploadFromGallery'] ?? 'Subir desde galería'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery(); // Llama a la función para seleccionar desde galería
            },
          ),
          CupertinoActionSheetAction(
            child: Text(widget.translations['uploadFromCamera'] ?? 'Subir desde cámara'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera(); // Llama a la función para seleccionar desde la cámara
            },
          ),
        ],
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
    print('Showing language selector');
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
                print('Selected language: English');
                widget.onChangeLanguage(_selectedLocale);
                Provider.of<UserDataProvider>(context, listen: false).saveUserData(
                    _nameController.text, _emailController.text, _phoneController.text, 'en', _passController.text, _referrerPassController.text);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Español'),
              onPressed: () {
                setState(() {
                  _selectedLocale = const Locale('es');
                });
                print('Selected language: Español');
                widget.onChangeLanguage(_selectedLocale);
                Provider.of<UserDataProvider>(context, listen: false).saveUserData(
                    _nameController.text, _emailController.text, _phoneController.text, 'es', _passController.text, _referrerPassController.text);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Deutsch'),
              onPressed: () {
                setState(() {
                  _selectedLocale = const Locale('de');
                });
                print('Selected language: Deutsch');
                widget.onChangeLanguage(_selectedLocale);
                Provider.of<UserDataProvider>(context, listen: false).saveUserData(
                    _nameController.text, _emailController.text, _phoneController.text, 'de', _passController.text, _referrerPassController.text);
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['close'] ?? 'Cerrar'),
            onPressed: () {
              print('Language selector closed');
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
