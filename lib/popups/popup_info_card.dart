import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/entity_detail_screen.dart';

class InfoCardPopup {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> translations,
    required VoidCallback onDismiss,
  }) {
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
                        title: data['name'] ??
                            translations['common']['noDataAvailable'] ??
                            'Not available',
                        address: data['address'] ??
                            translations['entities']?['noAddress'] ??
                            'Address not available',
                        phone: data['phone'] ??
                            translations['entities']?['noPhone'] ??
                            'Phone not available',
                        email: data['email'] ??
                            translations['entities']?['noEmail'] ??
                            'Email not available',
                        city: data['city'] ??
                            translations['entities']?['noCity'] ??
                            'City not available',
                        description: data['description'] ??
                            translations['entities']?['noDescription'] ??
                            'Description not available',
                        imageUrl: data['avatar_url'] ?? '',
                        backgroundImage: data['background_image'] ?? '',
                        fotosUrls: List<String>.from(data['fotos_urls'] ?? []),
                        translations: translations,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2 * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(data['background_image'] ?? ''),
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
                                  image: NetworkImage(data['avatar_url'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 0),
                        child: Row(
                          children: [
                            Icon(
                              data['is_open'] == true ? Icons.check : Icons.close,
                              color: data['is_open'] == true ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data['is_open'] == true
                                  ? translations['entities']['open'] ?? 'Open'
                                  : translations['entities']['closed'] ?? 'Closed',
                              style: TextStyle(
                                color: data['is_open'] == true ? Colors.green : Colors.red,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                        child: Text(
                          data['name'] ?? translations['common']['noDataAvailable'] ?? 'Not available',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
