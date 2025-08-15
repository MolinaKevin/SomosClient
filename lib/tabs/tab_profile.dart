import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../providers/user_data_provider.dart';

class TabProfile extends StatefulWidget {
  final Map<String, dynamic> translations;
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;

  const TabProfile({
    Key? key,
    required this.translations,
    required this.onChangeLanguage,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _TabProfileState createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  bool _isEditing = false;
  bool _avatarUpdated = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passController;
  late TextEditingController _referrerPassController;
  late Locale _selectedLocale;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passController = TextEditingController();
    _referrerPassController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userData = Provider.of<UserDataProvider>(context);
    _selectedLocale = Locale(userData.language ?? 'en');

    if (!_isEditing) {
      _nameController.text = userData.name != 'Name not available' ? userData.name : '';
      _emailController.text = userData.email != 'Email not available' ? userData.email : '';
      _phoneController.text = userData.phone != 'Phone not available' ? userData.phone : '';
      _passController.text = userData.pass != 'Not available' ? userData.pass : '';
      _referrerPassController.text = userData.referrerPass != 'Not available' ? userData.referrerPass : '';
    }

    print('User data updated: name = ${userData.name}, email = ${userData.email}, phone = ${userData.phone}, language = ${userData.language}, pass = ${userData.pass}, referrerPass = ${userData.referrerPass}');
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _avatarUpdated = true;
        _isEditing = true;
      });
      _showSuccessPopup();
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _avatarUpdated = true;
        _isEditing = true;
      });
      _showSuccessPopup();
    }
  }

  Future<void> _uploadAvatar(UserDataProvider userData) async {
    if (_avatarUpdated && _image != null) {
      await userData.uploadAvatar(_image!);
      _avatarUpdated = false;
    }
  }

  void _showSuccessPopup() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(widget.translations['common']['success'] ?? 'Success'),
          content: Text(widget.translations['common']['imageUploaded'] ?? 'Image uploaded successfully.'),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.translations['common']['ok'] ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
      print('Saving user data: name = ${_nameController.text}, email = ${_emailController.text}, phone = ${_phoneController.text}, language = ${_selectedLocale.languageCode}, pass = ${_passController.text}, referrerPass = ${_referrerPassController.text}');

      final updatedName = _nameController.text.isNotEmpty ? _nameController.text : userData.name;
      final updatedEmail = _emailController.text.isNotEmpty ? _emailController.text : userData.email;
      final updatedPhone = _phoneController.text.isNotEmpty ? _phoneController.text : userData.phone;
      final updatedPass = _passController.text.isNotEmpty ? _passController.text : userData.pass;
      final updatedReferrerPass = _referrerPassController.text.isNotEmpty ? _referrerPassController.text : userData.referrerPass;

      userData.saveUserData(
        updatedName,
        updatedEmail,
        updatedPhone,
        _selectedLocale.languageCode,
        updatedPass,
        updatedReferrerPass,
      );

      _uploadAvatar(userData);
    }
  }

  void _changePassword(BuildContext context) {
    print('Change password pressed');
  }

  Future<void> _logout(UserDataProvider userData) async {
    print('Logout pressed');
    await userData.logout();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginScreen(
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
        translations: widget.translations,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    print('Building Tab4 screen, _isEditing=$_isEditing');

    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: SingleChildScrollView(
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
                                '${widget.translations['user']['name'] ?? 'Name'}:',
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
                                '${widget.translations['user']['email'] ?? 'Email'}:',
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
                                '${widget.translations['user']['phone'] ?? 'Phone'}:',
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
                                '${widget.translations['common']['language'] ?? 'Language'}:',
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
                              Text(
                                '${widget.translations['user']['pass'] ?? 'Somos Pass'}:',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userData.pass ?? widget.translations['common']['noDataAvailable'] ?? 'Not available',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '${widget.translations['user']['referrer_pass'] ?? 'Referrer Pass'}:',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userData.referrerPass ?? widget.translations['common']['noDataAvailable'] ?? 'Not available',
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
                                ? FileImage(_image!)
                                : (userData.profilePhotoUrl.isNotEmpty
                                ? NetworkImage(userData.profilePhotoUrl)
                                : const NetworkImage('https://via.placeholder.com/150')) as ImageProvider,
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
                              ? widget.translations['common']['save'] ?? 'Save'
                              : widget.translations['user']['modifyProfile'] ?? 'Edit Profile',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        onPressed: () => _changePassword(context),
                        child: Text(widget.translations['user']['changePassword'] ?? 'Change Password'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CupertinoButton(
                        color: CupertinoColors.destructiveRed,
                        onPressed: () => _logout(userData),
                        child: Text(widget.translations['common']['logout'] ?? 'Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(widget.translations['user']['avatarOptions'] ?? 'Avatar Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(widget.translations['user']['uploadFromGallery'] ?? 'Upload from Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text(widget.translations['user']['uploadFromCamera'] ?? 'Upload from Camera'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(widget.translations['common']['close'] ?? 'Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    print('Showing language selector');
    final userData = Provider.of<UserDataProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['common']['selectLanguage'] ?? 'Select Language'),
          actions: [
            for (Locale locale in userData.availableLocales)
              CupertinoActionSheetAction(
                child: Text(
                  widget.translations['languages'][locale.languageCode] ?? locale.languageCode,
                ),
                onPressed: () {
                  setState(() {
                    _selectedLocale = locale;
                  });
                  print('Selected language: ${locale.languageCode}');
                  widget.onChangeLanguage(_selectedLocale);
                  userData.saveUserData(
                    _nameController.text,
                    _emailController.text,
                    _phoneController.text,
                    locale.languageCode,
                    _passController.text,
                    _referrerPassController.text,
                  );
                  Navigator.pop(context);
                },
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(widget.translations['common']['close'] ?? 'Close'),
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
