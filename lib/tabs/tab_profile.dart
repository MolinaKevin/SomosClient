import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';
import '../providers/user_data_provider.dart';
import '../ui/responsive.dart';

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
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

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
      _nameController.text  = userData.name  != 'Name not available'  ? userData.name  : '';
      _emailController.text = userData.email != 'Email not available' ? userData.email : '';
      _phoneController.text = userData.phone != 'Phone not available' ? userData.phone : '';
      _passController.text  = userData.pass  != 'Not available'       ? userData.pass  : '';
      _referrerPassController.text = userData.referrerPass != 'Not available' ? userData.referrerPass : '';
    }
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
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(widget.translations['common']['success'] ?? 'Success'),
        content: Text(widget.translations['common']['imageUploaded'] ?? 'Image uploaded successfully.'),
        actions: [
          CupertinoDialogAction(
            child: Text(widget.translations['common']['ok'] ?? 'OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _toggleEdit(UserDataProvider userData) {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      final updatedName   = _nameController.text.isNotEmpty ? _nameController.text : userData.name;
      final updatedEmail  = _emailController.text.isNotEmpty ? _emailController.text : userData.email;
      final updatedPhone  = _phoneController.text.isNotEmpty ? _phoneController.text : userData.phone;
      final updatedPass   = _passController.text.isNotEmpty ? _passController.text : userData.pass;
      final updatedRef    = _referrerPassController.text.isNotEmpty ? _referrerPassController.text : userData.referrerPass;
      userData.saveUserData(
        updatedName,
        updatedEmail,
        updatedPhone,
        _selectedLocale.languageCode,
        updatedPass,
        updatedRef,
      );
      _uploadAvatar(userData);
    }
  }

  void _changePassword(BuildContext context) {
    debugPrint('Change password pressed');
  }

  Future<void> _logout(UserDataProvider userData) async {
    await userData.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onChangeLanguage: widget.onChangeLanguage,
          currentLocale: widget.currentLocale,
          translations: widget.translations,
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, EdgeInsets? padding}) {
    final r = context.r;
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(r.r(16)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
      ),
      padding: padding ?? EdgeInsets.fromLTRB(r.r(16), r.r(14), r.r(16), r.r(16)),
      margin: EdgeInsets.symmetric(vertical: r.r(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _greenSoft,
              fontSize: r.fs(16, min: 12, max: 22),
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          SizedBox(height: r.r(10)),
          child,
        ],
      ),
    );
  }

  Widget _labelValue({
    required String label,
    required String value,
    TextEditingController? controller,
    TextInputType? keyboard,
  }) {
    final r = context.r;
    final isEditable = _isEditing && controller != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(13, min: 11, max: 18),
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: r.r(6)),
        isEditable
            ? CupertinoTextField(
          controller: controller,
          keyboardType: keyboard,
          padding: EdgeInsets.symmetric(horizontal: r.r(12), vertical: r.r(10)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.r(12)),
            border: Border.all(color: _greenSoft.withOpacity(.18)),
          ),
          style: TextStyle(fontSize: r.fs(16, min: 12, max: 20)),
        )
            : Text(
          value,
          style: TextStyle(
            fontSize: r.fs(17, min: 12, max: 22),
            fontWeight: FontWeight.w600,
            color: _greenDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _pillButton({
    required BuildContext ctx,
    required String label,
    required VoidCallback onPressed,
    Color background = _greenDark,
    Color foreground = Colors.white,
    IconData? icon,
  }) {
    final r = ctx.r;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: r.r(36)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: r.r(14), vertical: r.r(8)),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(r.r(24)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: r.fs(16, min: 12, max: 22), color: foreground),
                  SizedBox(width: r.r(6)),
                ],
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: r.fs(14, min: 11, max: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.translations['common']['selectLanguage'] ?? 'Select Language'),
          actions: [
            for (Locale locale in userData.availableLocales)
              CupertinoActionSheetAction(
                child: Text(widget.translations['languages'][locale.languageCode] ?? locale.languageCode),
                onPressed: () {
                  setState(() => _selectedLocale = locale);
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
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    final t = widget.translations;
    final r = context.r;

    final nameLabel   = t['user']['name'] ?? 'Name';
    final emailLabel  = t['user']['email'] ?? 'Email';
    final phoneLabel  = t['user']['phone'] ?? 'Phone';
    final langLabel   = t['common']['language'] ?? 'Language';
    final passLabel   = t['user']['pass'] ?? 'Somos Pass';
    final refPassLbl  = t['user']['referrer_pass'] ?? 'Referrer Pass';

    final editLbl     = t['user']['modifyProfile'] ?? 'Edit Profile';
    final saveLbl     = t['common']['save'] ?? 'Save';
    final changePwd   = t['user']['changePassword'] ?? 'Change Password';
    final logoutLbl   = t['common']['logout'] ?? 'Logout';

    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(r.r(16), r.r(18), r.r(16), r.r(28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(r.r(20)),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
                      ),
                      padding: EdgeInsets.all(r.r(16)),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(r.r(60)),
                            onTap: () => _showAvatarOptions(context),
                            child: CircleAvatar(
                              radius: r.r(42),
                              backgroundColor: _greenDark,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : (userData.profilePhotoUrl.isNotEmpty
                                  ? NetworkImage(userData.profilePhotoUrl)
                                  : const NetworkImage('https://via.placeholder.com/150')) as ImageProvider,
                            ),
                          ),
                          const Spacer(),
                          _pillButton(
                            ctx: context,
                            label: _isEditing ? saveLbl : editLbl,
                            icon: _isEditing ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.pencil_circle,
                            onPressed: () => _toggleEdit(userData),
                          ),
                        ],
                      ),
                    ),
                    _sectionCard(
                      title: t['user']['personalData'] ?? 'Personal data',
                      child: Column(
                        children: [
                          _labelValue(
                            label: nameLabel,
                            value: userData.name,
                            controller: _nameController,
                            keyboard: TextInputType.name,
                          ),
                          SizedBox(height: r.r(14)),
                          _labelValue(
                            label: emailLabel,
                            value: userData.email,
                            controller: _emailController,
                            keyboard: TextInputType.emailAddress,
                          ),
                          SizedBox(height: r.r(14)),
                          _labelValue(
                            label: phoneLabel,
                            value: userData.phone,
                            controller: _phoneController,
                            keyboard: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    _sectionCard(
                      title: langLabel,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: r.r(12), vertical: r.r(12)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(r.r(12)),
                                border: Border.all(color: _greenSoft.withOpacity(.18)),
                              ),
                              child: Text(
                                _selectedLocale.languageCode,
                                style: TextStyle(
                                  fontSize: r.fs(16, min: 12, max: 20),
                                  fontWeight: FontWeight.w700,
                                  color: _greenDark,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.r(10)),
                          _pillButton(
                            ctx: context,
                            label: t['common']['change'] ?? 'Change',
                            icon: CupertinoIcons.globe,
                            onPressed: () => _showLanguageSelector(context),
                            background: _greenSoft,
                          ),
                        ],
                      ),
                    ),
                    _sectionCard(
                      title: t['user']['access'] ?? 'Access',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelValue(
                            label: passLabel,
                            value: userData.pass ?? (t['common']['noDataAvailable'] ?? 'Not available'),
                            controller: _passController,
                          ),
                          SizedBox(height: r.r(14)),
                          _labelValue(
                            label: refPassLbl,
                            value: userData.referrerPass ?? (t['common']['noDataAvailable'] ?? 'Not available'),
                            controller: _referrerPassController,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.r(8)),
                    Row(
                      children: [
                        Expanded(
                          child: _pillButton(
                            ctx: context,
                            label: changePwd,
                            icon: CupertinoIcons.lock_shield_fill,
                            onPressed: () => _changePassword(context),
                            background: Colors.white,
                            foreground: _greenDark,
                          ),
                        ),
                        SizedBox(width: r.r(12)),
                        Expanded(
                          child: _pillButton(
                            ctx: context,
                            label: logoutLbl,
                            icon: CupertinoIcons.arrow_right_square_fill,
                            onPressed: () => _logout(userData),
                            background: CupertinoColors.destructiveRed,
                            foreground: Colors.white,
                          ),
                        ),
                      ],
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
}
