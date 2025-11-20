import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import 'auth_service.dart';

class TransactionService {
  List<Map<String, dynamic>>? _cachedPurchases;
  List<Map<String, dynamic>>? _cachedPointPurchases;
  List<Map<String, dynamic>>? _cachedReferralPoints;

  Future<String?> _getAuthToken() async {
    return await AuthService().getToken();
  }

  Future<List<Map<String, dynamic>>> fetchPurchases({bool forceRefresh = false}) async {
    if (_cachedPurchases != null && !forceRefresh) {
      return _cachedPurchases!;
    }

    final token = await _getAuthToken();
    if (token == null) {
      throw Exception("No auth token available");
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/purchases');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      _cachedPurchases = data.map<Map<String, dynamic>>((purchase) {
        return {
          'id': purchase['id'],
          'amount': purchase['amount'],
          'description': purchase['description'],
          'date': purchase['created_at'],
          'commerce': purchase['commerce'],
          'gived_to_users_points': purchase['gived_to_users_points'],
          'money': double.tryParse(purchase['money'].toString()) ?? 0.0,
          'points': double.tryParse(purchase['points'].toString()) ?? 0.0,
        };
      }).toList();
      return _cachedPurchases!;
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPointPurchases({bool forceRefresh = false}) async {
    if (_cachedPointPurchases != null && !forceRefresh) {
      return _cachedPointPurchases!;
    }

    final token = await _getAuthToken();
    if (token == null) {
      throw Exception("No auth token available");
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/point-purchases');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      _cachedPointPurchases = data.map<Map<String, dynamic>>((pointPurchase) {
        return {
          'id': pointPurchase['id'],
          'amount': pointPurchase['amount'],
          'description': pointPurchase['description'],
          'date': pointPurchase['created_at'],
          'points': double.tryParse(pointPurchase['points']?.toString() ?? '0') ?? 0.0,
        };
      }).toList();
      return _cachedPointPurchases!;
    } else {
      throw Exception('Failed to load point purchases');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReferralPoints({bool forceRefresh = false}) async {
    if (_cachedReferralPoints != null && !forceRefresh) {
      return _cachedReferralPoints!;
    }

    final token = await _getAuthToken();
    if (token == null) {
      throw Exception("No auth token available");
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/referral-points');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      _cachedReferralPoints = data.map<Map<String, dynamic>>((referralPoint) {
        return {
          'id': referralPoint['purchase_id'],
          'points': double.tryParse(referralPoint['points']?.toString() ?? '0') ?? 0.0,
          'date': referralPoint['created_at'],
          'referrer': referralPoint['referrer'],
        };
      }).toList();
      return _cachedReferralPoints!;
    } else {
      throw Exception('Failed to load referral points');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllTransactions({bool forceRefresh = false}) async {
    final purchases = await fetchPurchases(forceRefresh: forceRefresh);
    final pointPurchases = await fetchPointPurchases(forceRefresh: forceRefresh);
    final referralPoints = await fetchReferralPoints(forceRefresh: forceRefresh);

    final purchasesWithType = purchases.map((transaction) => {...transaction, 'type': 'purchase'}).toList();
    final pointPurchasesWithType = pointPurchases.map((transaction) => {...transaction, 'type': 'pointPurchase'}).toList();
    final referralPointsWithType = referralPoints.map((transaction) => {...transaction, 'type': 'referralPoint'}).toList();

    final allTransactions = [
      ...purchasesWithType,
      ...pointPurchasesWithType,
      ...referralPointsWithType
    ].where((transaction) => (transaction['points'] ?? 0) > 0).toList();

    allTransactions.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return allTransactions;
  }

  Future<Map<String, dynamic>> createMockTransaction({required double amount}) async {
    _cachedPurchases ??= [];
    _cachedPointPurchases ??= [];
    _cachedReferralPoints ??= [];

    final now = DateTime.now().toIso8601String();
    final rnd = Random();
    final types = ['purchase', 'pointPurchase', 'referralPoint'];
    final type = types[rnd.nextInt(types.length)];

    final pts = (amount * (0.05 + rnd.nextDouble() * 0.15)).clamp(0.1, double.infinity);
    final base = <String, dynamic>{'date': now, 'points': double.parse(pts.toStringAsFixed(2))};

    if (type == 'purchase') {
      final tx = {
        'id': 'mock-p-${now.hashCode}',
        'amount': amount,
        'description': 'Mock purchase',
        'commerce': {'name': 'Mock Store'},
        'gived_to_users_points': [],
        'money': amount,
        ...base,
      };
      _cachedPurchases!.insert(0, tx);
      return {...tx, 'type': 'purchase'};
    } else if (type == 'pointPurchase') {
      final tx = {
        'id': 'mock-pp-${now.hashCode}',
        'amount': amount,
        'description': 'Mock points buy',
        ...base,
      };
      _cachedPointPurchases!.insert(0, tx);
      return {...tx, 'type': 'pointPurchase'};
    } else {
      final tx = {
        'id': 'mock-rp-${now.hashCode}',
        'referrer': {'name': 'Mock Referrer'},
        ...base,
      };
      _cachedReferralPoints!.insert(0, tx);
      return {...tx, 'type': 'referralPoint'};
    }
  }
}
