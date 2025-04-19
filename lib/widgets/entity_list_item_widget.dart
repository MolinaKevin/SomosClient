import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/seal_icon_widget.dart';

class EntityListItemWidget extends StatelessWidget {
  final Map<String, dynamic> entity;
  final Map<String, dynamic> translations;
  final VoidCallback onTap;

  const EntityListItemWidget({
    Key? key,
    required this.entity,
    required this.translations,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: entity['avatar_url'] != null && entity['avatar_url'].isNotEmpty
            ? Image.asset(
          entity['avatar_url'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        )
            : const Icon(CupertinoIcons.photo, size: 50),
        title: Text(
          entity['name'] ?? translations['common']?['noDataAvailable'] ?? 'Not available',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${translations['entities']?['address'] ?? 'Address'}: ${entity['address']}',
            ),
            Text(
              '${translations['entities']?['phone'] ?? 'Phone'}: ${entity['phone']}',
            ),
            Text(
              '${translations['entities']?['category'] ?? 'Category'}: ${entity['category']}',
            ),
            if (entity['distance'] != null)
              Text(
                '${(entity['distance'] / 1000).toStringAsFixed(2)} ${translations['filter']?['location.kilometers'] ?? 'km'}',
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entity['seals_with_state'] != null &&
                (entity['seals_with_state'] as List).isNotEmpty)
              ...List<Map<String, dynamic>>.from(entity['seals_with_state'])
                  .where((seal) => seal['state'] == 'partial' || seal['state'] == 'full')
                  .take(3)
                  .map((seal) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SealIconWidget(seal: seal),
                );
              }),
            const Icon(CupertinoIcons.chevron_forward),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
