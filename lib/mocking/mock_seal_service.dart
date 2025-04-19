class MockSealService {
  List<Map<String, dynamic>>? _cachedSeals;

  Future<List<Map<String, dynamic>>> fetchSeals({bool forceRefresh = false}) async {
    if (_cachedSeals != null && !forceRefresh) {
      print('Using cached seals');
      return _cachedSeals!;
    }

    _cachedSeals = [
      {
        'id': 1,
        'name': 'Vegano',
        'slug': 'vegano',
        'image': 'lib/mocking/assets/seal_vegan/seal_vegan_::STATE::.svg',
      },
      {
        'id': 2,
        'name': 'Orgánico',
        'slug': 'organico',
        'image': 'lib/mocking/assets/seal_organic/seal_organic_::STATE::.svg',
      },
      {
        'id': 3,
        'name': 'Comercio Justo',
        'slug': 'comercio-justo',
        'image': 'lib/mocking/assets/seal_regional/::STATE::.svg',
      },
      {
        'id': 4,
        'name': 'Sin TACC',
        'slug': 'sin-tacc',
        'image': 'lib/mocking/assets/seal_regional/::STATE::.svg',
      },
      {
        'id': 5,
        'name': 'Libre de Plástico',
        'slug': 'libre-plastico',
        'image': 'lib/mocking/assets/seal_plastic/seal_plastic_::STATE::.svg',
      },
    ];

    print('Mocked seals loaded: $_cachedSeals');
    return _cachedSeals!;
  }
}
