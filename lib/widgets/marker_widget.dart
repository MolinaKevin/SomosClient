import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef InfoCardCallback = void Function(BuildContext context, Map<String, dynamic> data);

class MarkerWidget {
  static List<Marker> createMarkers({
    required BuildContext context,
    required List<Map<String, dynamic>> markerData,
    required String activeMarker,
    required InfoCardCallback onMarkerTap,
  }) {
    return markerData.map((data) {
      final double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
      final double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

      final String entityType =
      (data['type'] ?? data['entity_type'] ?? '').toString().toLowerCase();
      final bool isInstitution =
          entityType.contains('institution') || entityType.contains('ngo') || entityType.contains('nro');

      final bool isActive = activeMarker == data['id'].toString();

      final Color fillColor = isInstitution
          ? const Color(0xFF103D1B)
          : const Color(0xFFfeba66);

      final Color borderColor = isActive ? Colors.amberAccent : Colors.white;

      final IconData? markerIcon = _resolveIcon(data);

      return Marker(
        point: LatLng(latitude, longitude),
        width: isActive ? 46 : 38,
        height: isActive ? 46 : 38,
        child: GestureDetector(
          onTap: () => onMarkerTap(context, data),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 46 : 38,
            height: isActive ? 46 : 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(color: borderColor, width: isActive ? 4 : 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: markerIcon != null
                  ? Icon(
                markerIcon,
                color: Colors.white,
                size: isActive ? 22 : 18,
              )
                  : null,
            ),
          ),
        ),
      );
    }).toList();
  }

  static IconData? _resolveIcon(Map<String, dynamic> data) {
    final String? iconName = (data['icon'] ?? '').toString().toLowerCase();
    switch (iconName) {
      case 'store':
      case 'commerce':
        return Icons.storefront;
      case 'ngo':
      case 'institution':
      case 'nro':
        return Icons.volunteer_activism;
      case 'food':
        return Icons.restaurant;
      case 'gift':
        return Icons.card_giftcard;
      case 'default':
        return Icons.location_pin;
      default:
        return Icons.location_pin;
    }
  }
}
