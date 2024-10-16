import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EntityDetailScreen extends StatelessWidget {
  final String title;
  final String address;
  final String phone;
  final String imageUrl;
  final String email;
  final String city;
  final String description;
  final String backgroundImage;
  final List<String> fotosUrls;
  final Map<String, String> translations;

  const EntityDetailScreen({
    super.key,
    required this.title,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.email,
    required this.city,
    required this.description,
    required this.backgroundImage,
    required this.fotosUrls,
    required this.translations, // Pasamos translations
  });

  @override
  Widget build(BuildContext context) {
    final List<String> allFotos = backgroundImage.isNotEmpty
        ? [backgroundImage, ...fotosUrls]
        : fotosUrls;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(backgroundImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: MediaQuery.of(context).size.width / 2 - 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${translations['address'] ?? 'Dirección'}: $address', // Traducir Dirección
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${translations['phone'] ?? 'Teléfono'}: $phone', // Traducir Teléfono
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${translations['email'] ?? 'Correo electrónico'}: $email', // Traducir Email
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${translations['city'] ?? 'Ciudad'}: $city', // Traducir Ciudad
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${translations['description'] ?? 'Descripción'}: $description', // Traducir Descripción
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      translations['gallery'] ?? 'Galería:', // Traducir Galería
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allFotos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showImagePopup(context, allFotos, index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  allFotos[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      CupertinoIcons.photo,
                                      size: 120,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePopup(BuildContext context, List<String> allFotos, int initialIndex) {
    PageController pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoPageScaffold(
              backgroundColor: Colors.black.withOpacity(0.9),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: allFotos.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: InteractiveViewer(
                          child: Image.network(
                            allFotos[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                CupertinoIcons.photo,
                                size: 100,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if (currentIndex > 0)
                    Positioned(
                      left: 10,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        onPressed: () {
                          if (currentIndex > 0) {
                            pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        },
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  if (currentIndex < allFotos.length - 1)
                    Positioned(
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        onPressed: () {
                          if (currentIndex < allFotos.length - 1) {
                            pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        },
                        child: const Icon(Icons.arrow_forward, color: Colors.black),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
