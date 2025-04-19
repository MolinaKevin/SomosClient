class MockTransactionService {
  List<Map<String, dynamic>>? _cachedPurchases;
  List<Map<String, dynamic>>? _cachedPointPurchases;
  List<Map<String, dynamic>>? _cachedReferralPoints;

  Future<List<Map<String, dynamic>>> fetchPurchases({bool forceRefresh = false}) async {
    if (_cachedPurchases != null && !forceRefresh) return _cachedPurchases!;

    await Future.delayed(Duration(milliseconds: 200)); // Simula delay de red

    _cachedPurchases = [
      {
        'id': 1,
        'amount': 50,
        'description': 'Purchase at Test Commerce',
        'date': '2024-04-10T12:30:00Z',
        'commerce': 'Test Commerce',
        'gived_to_users_points': 5,
        'money': 50.0,
        'points': 5.0,
      },
      {
        'id': 2,
        'amount': 80,
        'description': 'Another Commerce Purchase',
        'date': '2024-04-09T10:00:00Z',
        'commerce': 'Shop Two',
        'gived_to_users_points': 8,
        'money': 80.0,
        'points': 8.0,
      },
    ];
    return _cachedPurchases!;
  }

  Future<List<Map<String, dynamic>>> fetchPointPurchases({bool forceRefresh = false}) async {
    if (_cachedPointPurchases != null && !forceRefresh) return _cachedPointPurchases!;

    await Future.delayed(Duration(milliseconds: 200));

    _cachedPointPurchases = [
      {
        'id': 10,
        'amount': 100,
        'description': 'Purchased with Points',
        'date': '2024-04-08T15:00:00Z',
      },
    ];
    return _cachedPointPurchases!;
  }

  Future<List<Map<String, dynamic>>> fetchReferralPoints({bool forceRefresh = false}) async {
    if (_cachedReferralPoints != null && !forceRefresh) return _cachedReferralPoints!;

    await Future.delayed(Duration(milliseconds: 200));

    _cachedReferralPoints = [
      {
        'id': 3,
        'points': 15,
        'date': '2024-04-07T11:45:00Z',
        'referrer': 'Sophie R.',
      },
    ];
    return _cachedReferralPoints!;
  }

  Future<List<Map<String, dynamic>>> fetchAllTransactions({bool forceRefresh = false}) async {
    final purchases = await fetchPurchases(forceRefresh: forceRefresh);
    final pointPurchases = await fetchPointPurchases(forceRefresh: forceRefresh);
    final referralPoints = await fetchReferralPoints(forceRefresh: forceRefresh);

    final purchasesWithType = purchases.map((t) => {...t, 'type': 'purchase'}).toList();
    final pointPurchasesWithType = pointPurchases.map((t) => {...t, 'type': 'pointPurchase'}).toList();
    final referralPointsWithType = referralPoints.map((t) => {...t, 'type': 'referralPoint'}).toList();

    final all = [
      ...purchasesWithType,
      ...pointPurchasesWithType,
      ...referralPointsWithType
    ];

    all.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    return all;
  }
}
