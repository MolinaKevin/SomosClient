import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../screens/entity_detail_screen.dart';
import '../widgets/seal_icon_widget.dart';

class InfoCardPopup {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> translations,
    required List<Map<String, dynamic>> allSeals,
    required VoidCallback onDismiss,
  }) {
    print('InfoCardPopup.show - Comercio data: $data');
    print('InfoCardPopup.show - All seals: $allSeals');

    final sealsWithStateData = data['seals_with_state'];
    final hasSeals = sealsWithStateData != null && (sealsWithStateData as List).isNotEmpty;

    if (!hasSeals) {
      print('InfoCardPopup: no seals_with_state or it is empty');
    } else {
      print('InfoCardPopup: seals_with_state = $sealsWithStateData');
    }

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: MediaQuery.of(context).size.height * 0.1 * 0.7,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EntityDetailScreen(
                        title: data['name'] ?? translations['common']['noDataAvailable'] ?? 'Not available',
                        address: data['address'] ?? translations['entities']?['noAddress'] ?? 'Address not available',
                        phone: data['phone'] ?? translations['entities']?['noPhone'] ?? 'Phone not available',
                        email: data['email'] ?? translations['entities']?['noEmail'] ?? 'Email not available',
                        city: data['city'] ?? translations['entities']?['noCity'] ?? 'City not available',
                        description: data['description'] ?? translations['entities']?['noDescription'] ?? 'Description not available',
                        imageUrl: data['avatar_url'] ?? '',
                        backgroundImage: data['background_image'] ?? '',
                        fotosUrls: List<String>.from(data['fotos_urls'] ?? []),
                        translations: translations,
                        seals: List<Map<String, dynamic>>.from(data['seals_with_state'] ?? []).where(
                              (seal) => seal['state'] == 'partial' || seal['state'] == 'full',
                        ).toList(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2 * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(data['background_image'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 0, top: 100),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(data['avatar_url'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        data['is_open'] == true ? Icons.check : Icons.close,
                                        color: data['is_open'] == true ? Colors.green : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        data['is_open'] == true
                                            ? (translations['entities']?['open']) ?? 'Open'
                                            : (translations['entities']?['closed']) ?? 'Closed',
                                        style: TextStyle(
                                          color: data['is_open'] == true ? Colors.green : Colors.red,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['name'] ?? translations['common']['noDataAvailable'] ?? 'Not available',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (hasSeals)
                              Container(
                                margin: const EdgeInsets.only(left: 8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List<Map<String, dynamic>>.from(sealsWithStateData)
                                        .where((sealState) => sealState['state'] == 'partial' || sealState['state'] == 'full')
                                        .map((sealState) {
                                      final combinedSeal = allSeals.firstWhere(
                                            (seal) => seal['id'] == sealState['id'],
                                        orElse: () => {},
                                      );

                                      if (combinedSeal.isNotEmpty) {
                                        final completeSeal = {
                                          ...combinedSeal,
                                          'state': sealState['state'],
                                        };
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: SealIconWidget(seal: completeSeal),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }).toList(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ).drive(
            Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ),
          ),
          child: child,
        );
      },
    ).then((_) {
      onDismiss();
    });
  }
}

class _SealsColumn extends StatelessWidget {
  final List<Map<String, dynamic>> sealsWithState;
  final List<Map<String, dynamic>> allSeals;

  const _SealsColumn({required this.sealsWithState, required this.allSeals});

  @override
  Widget build(BuildContext context) {
    print('_SealsColumn: sealsWithState=$sealsWithState');
    print('_SealsColumn: allSeals=$allSeals');

    final combined = sealsWithState.map((sws) {
      final baseSeal = allSeals.firstWhere((s) => s['id'] == sws['id'], orElse: () {
        print('_SealsColumn: No base seal found for id=${sws['id']}');
        return {};
      });
      return {
        ...baseSeal,
        'state': sws['state'] ?? 'none',
      };
    }).where((seal) => seal['id'] != null && seal['state'] != 'none').toList();

    print('_SealsColumn: combined after filter=$combined');

    if (combined.isEmpty) {
      print('_SealsColumn: No active seals to show.');
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: combined.map((seal) {
          print('_SealsColumn: showing seal $seal');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SealIconWidget(seal: seal),
          );
        }).toList(),
      ),
    );
  }
}