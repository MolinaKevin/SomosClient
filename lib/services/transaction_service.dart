import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import 'auth_service.dart';

class TransactionService {
  List<Map<String, dynamic>>? _cachedPurchases;
  List<Map<String, dynamic>>? _cachedPointPurchases;
  List<Map<String, dynamic>>? _cachedReferralPoints;

  // Helper to retrieve the token from AuthService
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
    print('Response body for purchases: ${response.body}');

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
    print('Response body for point purchases: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      _cachedPointPurchases = data.map<Map<String, dynamic>>((pointPurchase) {
        return {
          'id': pointPurchase['id'],
          'amount': pointPurchase['amount'],
          'description': pointPurchase['description'],
          'date': pointPurchase['created_at'],
        };
      }).toList();
      return _cachedPointPurchases!;
    } else {
      throw Exception('Failed to load point purchases');
    }
  }

  // Fetch referral points with caching
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
    print('Response body for referral points: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      _cachedReferralPoints = data.map<Map<String, dynamic>>((referralPoint) {
        return {
          'id': referralPoint['purchase_id'],
          'points': double.tryParse(referralPoint['points']) ?? 0.0, // Convertir a double
          'date': referralPoint['created_at'],
          'referrer': referralPoint['referrer'], // Información del referido si está disponible
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

    // Add transaction type and merge the lists
    final purchasesWithType = purchases.map((transaction) {
      return {...transaction, 'type': 'purchase'};
    }).toList();

    final pointPurchasesWithType = pointPurchases.map((transaction) {
      return {...transaction, 'type': 'pointPurchase'};
    }).toList();

    final referralPointsWithType = referralPoints.map((transaction) {
      return {...transaction, 'type': 'referralPoint'};
    }).toList();

    // Combine all transactions and filter out those with points equal to 0
    final allTransactions = [
      ...purchasesWithType,
      ...pointPurchasesWithType,
      ...referralPointsWithType
    ].where((transaction) => (transaction['points'] ?? 0) > 0).toList();

    // Sort transactions by date in descending order
    allTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });

    return allTransactions;
  }

}
