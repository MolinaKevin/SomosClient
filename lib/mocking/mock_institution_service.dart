class MockInstitutionService {
  List<Map<String, dynamic>>? _cachedInstitutions;

  Future<List<Map<String, dynamic>>> fetchInstitutions({bool forceRefresh = false}) async {
    if (_cachedInstitutions != null && !forceRefresh) {
      return _cachedInstitutions!;
    }

    _cachedInstitutions = [
      {
        'id': 3,
        'name': "Green Hope Center",
        'description': "A non-profit focused on environmental education.",
        'address': "456 Sustainability Way",
        'city': "EcoTown",
        'plz': "54321",
        'email': "contact@greenhope.org",
        'phone_number': "555-123-4567",
        'website': "https://greenhope.org",
        'opening_time': "08:00:00",
        'closing_time': "18:00:00",
        'latitude': "51.5350",
        'longitude': "9.9400",
        'points': "85.75",
        'percent': "12.00",
        'contributed_points': 40.5,
        'to_contribute': 5.0,
        'created_at': "2024-06-10T10:00:00",
        'updated_at': "2024-10-10T15:45:00",
        'somos_id': 2,
        'active': true,
        'accepted': true,
        'avatar': null,
        'background_image_id': null,
        'is_open': true,
        'avatar_url': "lib/mocking/assets/avatar_gv.png",
        'background_image': "lib/mocking/assets/background_4.png",
        'fotos_urls': [
          "lib/mocking/assets/background_5.png",
          "lib/mocking/assets/background_6.png",
        ],
      },
      {
        'id': 4,
        'name': "Community First Aid",
        'description': "Local institution providing emergency first aid education.",
        'address': "789 Health Ave",
        'city': "Helpville",
        'plz': "67890",
        'email': "support@cfa.local",
        'phone_number': "555-987-6543",
        'website': "https://communityfirstaid.org",
        'opening_time': "10:00:00",
        'closing_time': "16:00:00",
        'latitude': "51.5148",
        'longitude': "9.9415",
        'points': "250.00",
        'percent': "7.25",
        'contributed_points': 120.0,
        'to_contribute': 10.0,
        'created_at': "2024-07-01T12:30:00",
        'updated_at': "2024-11-01T09:15:00",
        'somos_id': 4,
        'active': false,
        'accepted': true,
        'avatar': null,
        'background_image_id': null,
        'is_open': false,
        'avatar_url': "lib/mocking/assets/avatar_gv.png",
        'background_image': "lib/mocking/assets/background_7.png",
        'fotos_urls': [
          "lib/mocking/assets/background_8.png",
        ],
      },
    ];

    return _cachedInstitutions!;
  }
}
