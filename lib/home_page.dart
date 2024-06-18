import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'tabs/tab4.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, String> translations;
  final Function(Locale) onChangeLanguage;

  const MyHomePage({super.key, required this.translations, required this.onChangeLanguage});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<String> _tabTitles = [
      localizations.translate('map'),
      localizations.translate('list'),
      localizations.translate('points'),
      localizations.translate('buy'),
      localizations.translate('generateTransaction'),
    ];

    List<Widget> tabs = [
      Tab1(scaffoldKey: _scaffoldKey),
      Tab2(translations: widget.translations),
      Tab3(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage),
      Tab4(translations: widget.translations, onChangeLanguage: widget.onChangeLanguage),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: CupertinoNavigationBar(
        middle: Text(_tabTitles[_currentIndex]),
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(CupertinoIcons.bars),
            );
          },
        ),
        trailing: _currentIndex == 1
            ? Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: const Icon(CupertinoIcons.search),
            );
          },
        )
            : null,
      ),
      body: SafeArea(
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.map),
                label: localizations.translate('map'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.phone),
                label: localizations.translate('list'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.bitcoin),
                label: localizations.translate('points'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.profile_circled),
                label: localizations.translate('profile'),
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          tabBuilder: (BuildContext context, int index) {
            return tabs[_currentIndex];
          },
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: _buildProfileInfo(localizations),
          ),
        ),
      ),
      endDrawer: const Drawer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Información del marcador')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AppLocalizations localizations) {
    return CupertinoActionSheet(
      title: Text(localizations.translate('userProfile')),
      message: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${localizations.translate('name')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Juan Pérez',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('email')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'juan.perez@example.com',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('phone')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '+1 234 567 8900',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            '${localizations.translate('points')}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '25555',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      cancelButton: CupertinoActionSheetAction(
        child: Text(localizations.translate('description')),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
