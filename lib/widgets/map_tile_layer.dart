import 'package:flutter_map/flutter_map.dart';

TileLayer buildBaseTileLayer({required bool useLocalTiles}) {
  return TileLayer(
    urlTemplate: useLocalTiles
        ? 'http://localhost:8080/styles/positron/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png',
    subdomains: useLocalTiles ? const [] : const ['a', 'b', 'c', 'd'],
  );
}
