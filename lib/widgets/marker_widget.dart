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
      double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
      double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;

      return Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => onMarkerTap(context, data),
          child: Image.asset(
            activeMarker == data['id'].toString()
                ? 'assets/images/active_marker.png'
                : 'assets/images/map_marker.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }).toList();
  }
}
