import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilterWidget extends StatelessWidget {
  final Map<String, dynamic> translations;
  final List<String> availableCategories;
  final Function(String category) onCategorySelected;
  final Function(double? distance) onDistanceSelected;
  final Function(bool isOpen) onToggleOpenNow;
  final VoidCallback onResetFilters;

  const FilterWidget({
    Key? key,
    required this.translations,
    required this.availableCategories,
    required this.onCategorySelected,
    required this.onDistanceSelected,
    required this.onToggleOpenNow,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLocationSupported =
        Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || kIsWeb;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(translations['filter']?['options'] ?? 'Filter Options'),
              actions: [
                CupertinoActionSheetAction(
                  child: Text(translations['filter']?['category'] ?? 'Filter by category'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showCategoryFilter(context);
                  },
                ),
                if (isLocationSupported)
                  CupertinoActionSheetAction(
                    child: Text(translations['filter']?['location'] ?? 'Filter by location'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDistanceFilter(context);
                    },
                  ),
                CupertinoActionSheetAction(
                  child: Text(translations['filter']?['openNow'] ?? 'Show only open'),
                  onPressed: () {
                    onToggleOpenNow(true);
                    Navigator.pop(context);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(translations['filter']?['resetFilters'] ?? 'Reset Filters'),
                  onPressed: () {
                    onResetFilters();
                    Navigator.pop(context);
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text(translations['common']?['close'] ?? 'Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
      child: const Icon(CupertinoIcons.search),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final filteredCategories = availableCategories.toSet().toList();
    if (!filteredCategories.contains('All')) {
      filteredCategories.insert(0, 'All');
    }

    print('Original availableCategories: $availableCategories');
    print('Filtered availableCategories (no duplicates): $filteredCategories');

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(translations['filter']?['category'] ?? 'Filter by category'),
          actions: filteredCategories.map((category) {
            return CupertinoActionSheetAction(
              child: Text(category),
              onPressed: () {
                print('Selected category: $category');
                onCategorySelected(category);
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: Text(translations['common']?['cancel'] ?? 'Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDistanceFilter(BuildContext context) {
    List<double?> distancesInMeters = [null, 2000, 5000, 10000, 25000, 50000, 100000, 200000];
    List<String> distanceOptions = [
      translations['filter']?['location.all'] ?? 'All locations',
      '+2km',
      '+5km',
      '+10km',
      '+25km',
      '+50km',
      '+100km',
      '+200km',
    ];

    print('Distance filter options: $distanceOptions');

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(translations['filter']?['location'] ?? 'Filter by location'),
          actions: List.generate(distancesInMeters.length, (index) {
            return CupertinoActionSheetAction(
              child: Text(distanceOptions[index]),
              onPressed: () {
                print('Selected distance: ${distancesInMeters[index]}');
                onDistanceSelected(distancesInMeters[index]);
                Navigator.pop(context);
              },
            );
          }),
          cancelButton: CupertinoActionSheetAction(
            child: Text(translations['common']?['cancel'] ?? 'Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
