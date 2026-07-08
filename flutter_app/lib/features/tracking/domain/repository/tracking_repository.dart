import '../../../../core/network/api_client.dart';
import '../models/bus.dart';
import '../models/route.dart';

abstract class TrackingRepository {
  Future<List<Bus>> fetchLiveBuses();
  Future<Map<String, dynamic>> fetchBusDetails(int busId);
  Future<List<BusRoute>> fetchRoutes();
  Future<BusRoute> fetchRouteDetails(int routeId);
  Future<Map<String, dynamic>> searchRoutes({
    required double startLat,
    required double startLon,
    required double destLat,
    required double destLon,
    required String userType,
  });
  Future<Map<String, dynamic>> postReview({
    required int busId,
    required int rating,
    required String comment,
    required int cleanliness,
    required int comfort,
    required int driverBehavior,
    required int punctuality,
  });
  Future<Map<String, dynamic>> fileSosReport({
    required int busId,
    required String category,
    required String description,
  });
}

class TrackingRepositoryImpl implements TrackingRepository {
  final ApiClient apiClient;

  TrackingRepositoryImpl({required this.apiClient});

  @override
  Future<List<Bus>> fetchLiveBuses() async {
    final List<dynamic> data = await apiClient.get('/buses');
    return data.map((json) => Bus.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchBusDetails(int busId) async {
    final dynamic data = await apiClient.get('/buses/$busId');
    return data as Map<String, dynamic>;
  }

  @override
  Future<List<BusRoute>> fetchRoutes() async {
    final List<dynamic> data = await apiClient.get('/routes');
    return data.map((json) => BusRoute.fromJson(json)).toList();
  }

  @override
  Future<BusRoute> fetchRouteDetails(int routeId) async {
    final dynamic data = await apiClient.get('/routes/$routeId');
    return BusRoute.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> searchRoutes({
    required double startLat,
    required double startLon,
    required double destLat,
    required double destLon,
    required String userType,
  }) async {
    final dynamic data = await apiClient.post('/route-search', {
      'startLat': startLat,
      'startLon': startLon,
      'destLat': destLat,
      'destLon': destLon,
      'userType': userType,
    });
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> postReview({
    required int busId,
    required int rating,
    required String comment,
    required int cleanliness,
    required int comfort,
    required int driverBehavior,
    required int punctuality,
  }) async {
    final dynamic data = await apiClient.post('/reviews', {
      'busId': busId,
      'rating': rating,
      'comment': comment,
      'cleanlinessScore': cleanliness,
      'comfortScore': comfort,
      'driverBehaviorScore': driverBehavior,
      'punctualityScore': punctuality,
    });
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fileSosReport({
    required int busId,
    required String category,
    required String description,
  }) async {
    final dynamic data = await apiClient.post('/reports', {
      'busId': busId,
      'category': category,
      'description': description,
    });
    return data as Map<String, dynamic>;
  }
}
