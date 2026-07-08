class RouteStop {
  final int id;
  final String name;
  final double lat;
  final double lon;
  final bool shelter;
  final List<String> facilities;
  final int sequenceOrder;
  final double distanceFromStartKm;
  final int fareStage;

  RouteStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.shelter,
    required this.facilities,
    required this.sequenceOrder,
    required this.distanceFromStartKm,
    required this.fareStage,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      shelter: json['shelter'] ?? false,
      facilities: List<String>.from(json['facilities'] ?? []),
      sequenceOrder: json['sequenceOrder'] ?? 1,
      distanceFromStartKm: (json['distanceFromStartKm'] as num?)?.toDouble() ?? 0.0,
      fareStage: json['fareStage'] ?? 1,
    );
  }
}

class BusRoute {
  final int id;
  final String routeNumber;
  final String name;
  final double distanceKm;
  final int durationMins;
  final String operatingHours;
  final int frequencyMins;
  final double baseFare;
  final List<RouteStop> stops;

  BusRoute({
    required this.id,
    required this.routeNumber,
    required this.name,
    required this.distanceKm,
    required this.durationMins,
    required this.operatingHours,
    required this.frequencyMins,
    required this.baseFare,
    required this.stops,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    var stopList = json['stopsList'] as List? ?? [];
    List<RouteStop> parsedStops = stopList.map((s) => RouteStop.fromJson(s)).toList();

    return BusRoute(
      id: json['id'] ?? 0,
      routeNumber: json['routeNumber'] ?? '',
      name: json['name'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMins: json['durationMins'] ?? 0,
      operatingHours: json['operatingHours'] ?? '',
      frequencyMins: json['frequencyMins'] ?? 0,
      baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
      stops: parsedStops,
    );
  }
}
