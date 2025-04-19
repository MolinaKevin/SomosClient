import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/seal_icon_widget.dart';

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
  final List<Map<String, dynamic>> seals;
  final Map<String, dynamic> translations;

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
    required this.seals,
    required this.translations,
  });

  List<Map<String, dynamic>> _combineSeals() {
    final List<Map<String, dynamic>> baseSeals = [
      {'id': 3, 'image': 'seals/default/::STATE::.svg'},
      {'id': 5, 'image': 'seals/default/::STATE::.svg'},
      {'id': 2, 'image': 'seals/default/::STATE::.svg'},
    ];

    return seals.map((seal) {
      final baseSeal = baseSeals.firstWhere(
            (b) => b['id'] == seal['id'],
        orElse: () => {},
      );

      return {
        ...seal,
        'image': baseSeal['image'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> combinedSeals = _combineSeals();
    print('EntityDetailScreen - Combined Seals: $combinedSeals');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoText('Address', address),
                    _buildInfoText('Phone', phone),
                    _buildInfoText('Email', email),
                    _buildInfoText('City', city),
                    _buildInfoText('Description', description),
                    if (combinedSeals.isNotEmpty) _buildSealsSection(combinedSeals),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        if (backgroundImage.isNotEmpty)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('$backgroundImage'),
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
                image: AssetImage('$imageUrl'),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildSealsSection(List<Map<String, dynamic>> seals) {
    print('Building Seals Section - Total seals: ${seals.length}');
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translations['entities']?['seals'] ?? 'Seals:',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: seals.length,
              itemBuilder: (context, index) {
                final seal = seals[index];
                print('Rendering Seal - index: $index, seal: $seal');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SealIconWidget(seal: seal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
