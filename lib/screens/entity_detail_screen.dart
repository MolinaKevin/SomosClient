import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/seal_icon_widget.dart';

class EntityDetailScreen extends StatelessWidget {
  static const _cream = Color(0xFFFFF5E6);
  static const _greenDark = Color(0xFF103D1B);
  static const _greenSoft = Color(0xFF2F5E3B);

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

  bool get _hasBackgroundImage =>
      backgroundImage.isNotEmpty == true && Uri.tryParse(backgroundImage) != null;

  bool get _hasDescription => description.trim().isNotEmpty;

  bool get _hasFotos => fotosUrls.isNotEmpty;

  bool get _hasSeals => seals.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = translations;
    final addressLabel = t['entities']?['address'] ?? 'Address';
    final phoneLabel = t['entities']?['phone'] ?? 'Phone';
    final emailLabel = t['entities']?['email'] ?? 'Email';
    final cityLabel = t['entities']?['city'] ?? 'City';
    final descLabel = t['entities']?['description'] ?? 'Description';
    final fotosLabel = t['entities']?['photos'] ?? 'Photos';
    final sealsLabel = t['entities']?['seals'] ?? 'Seals';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _cream.withOpacity(.96),
        border: const Border(bottom: BorderSide(color: Colors.transparent)),
        middle: Text(
          title,
          style: const TextStyle(
            color: _greenDark,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                if (_hasBackgroundImage || _hasFotos)
                  _sectionCard(
                    title: fotosLabel,
                    child: _buildPhotosSection(),
                  ),
                _sectionCard(
                  title: t['entities']?['info'] ?? 'Information',
                  child: Column(
                    children: [
                      _labelValue(label: addressLabel, value: address),
                      const SizedBox(height: 12),
                      _labelValue(label: phoneLabel, value: phone),
                      const SizedBox(height: 12),
                      _labelValue(label: emailLabel, value: email),
                      const SizedBox(height: 12),
                      _labelValue(label: cityLabel, value: city),
                    ],
                  ),
                ),
                if (_hasDescription)
                  _sectionCard(
                    title: descLabel,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                if (_hasSeals)
                  _sectionCard(
                    title: sealsLabel,
                    child: _buildSealsRow(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: _greenDark,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage('$imageUrl?${DateTime.now().millisecondsSinceEpoch}')
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : (translations['common']?['noDataAvailable'] ?? 'Not available'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _greenDark,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                if (city.isNotEmpty)
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (address.isNotEmpty) const SizedBox(height: 4),
                if (address.isNotEmpty)
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
        border: Border.all(color: _greenSoft.withOpacity(.12), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _greenSoft,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _labelValue({required String label, required String value}) {
    final safeValue = value.isNotEmpty
        ? value
        : (translations['common']?['noDataAvailable'] ?? 'Not available');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          safeValue,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _greenDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    final List<String> allFotos = [
      if (_hasBackgroundImage) backgroundImage,
      ...fotosUrls,
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allFotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final url = allFotos[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.black12,
                child: Image.network(
                  '$url?${DateTime.now().millisecondsSinceEpoch}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(CupertinoIcons.photo, color: Colors.black26),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSealsRow() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seals.length,
        itemBuilder: (context, index) {
          final seal = seals[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SealIconWidget(seal: seal, size: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
