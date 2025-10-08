import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../home_page.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;
  final Map<String, dynamic> translations;

  const LoginScreen({
    Key? key,
    required this.onChangeLanguage,
    required this.currentLocale,
    required this.translations,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const cream = Color(0xFFF7EFE4);
  static const green = Color(0xFF103D1B);
  static const loginText = Color(0xFF4D8348);

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  String _t(String section, String key, String fallback) =>
      widget.translations[section]?[key] ?? fallback;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack(_t('auth', 'enterCredentials', 'Please enter your credentials'));
      return;
    }
    final result = await _auth.login(email, password);
    if (mounted && result['success'] == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MyHomePage(
          translations: widget.translations,
          onChangeLanguage: widget.onChangeLanguage,
          currentLocale: widget.currentLocale,
          initialIndex: 0,
          isAuthenticated: true,
        ),
      ));
    } else {
      _showErrorMessage(result['error']);
    }
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnack(_t('auth', 'enterAllFields', 'Please fill in all fields'));
      return;
    }
    if (pass != confirm) {
      _showSnack(_t('auth', 'passwordsDontMatch', 'Passwords do not match'));
      return;
    }
    final result = await _auth.register(name, email, pass, confirm);
    if (mounted && result['success'] == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MyHomePage(
          translations: widget.translations,
          onChangeLanguage: widget.onChangeLanguage,
          currentLocale: widget.currentLocale,
          initialIndex: 0,
          isAuthenticated: true,
        ),
      ));
    } else {
      _showErrorMessage(result['error']);
    }
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MyHomePage(
        translations: widget.translations,
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
        initialIndex: 0,
        isAuthenticated: false,
      ),
    ));
  }

  void _showErrorMessage(Map<String, dynamic> errorData) {
    final msg = errorData.values.join('\n');
    _showSnack(msg);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showAuthSheet({required bool isLogin}) async {
    if (isLogin) {
      _passCtrl.clear();
    } else {
      _nameCtrl.clear();
      _passCtrl.clear();
      _confirmCtrl.clear();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12, borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                isLogin ? _t('auth', 'login', 'Log in') : _t('auth', 'register', 'Sign up'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 18),
              if (!isLogin) ...[
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: _t('auth', 'fullName', 'Full Name')),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: _t('user', 'email', 'Email')),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
                decoration: InputDecoration(labelText: _t('auth', 'password', 'Password')),
              ),
              if (!isLogin) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(labelText: _t('auth', 'confirmPassword', 'Confirm Password')),
                ),
              ],
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: isLogin ? _login : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                child: Text(isLogin ? _t('auth', 'login', 'Log in') : _t('auth', 'register', 'Sign up')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final gapAboveButtons = h * 0.60;

    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth/auth_bg.png',
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 144),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Center(
                    child: Image.asset(
                      'assets/images/auth/logo_somos.png',
                      height: h * 0.09,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: gapAboveButtons),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showAuthSheet(isLogin: true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: cream,
                        foregroundColor: loginText,
                        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(92),
                          side: BorderSide(color: green.withOpacity(0.25), width: 1),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Log in', style: TextStyle(color: loginText)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showAuthSheet(isLogin: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: cream,
                        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(52),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Sign up', style: TextStyle(color: cream)),
                    ),
                  ),

                  const SizedBox(height: 28),

                  TextButton(
                    onPressed: _skipLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Skip for now',
                          style: TextStyle(
                            color: green,
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_ios, size: 18, color: green),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
