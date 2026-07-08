class Bus {
  final int id;
  final String busNumber;
  final String busName;
  final String operatorName;
  final String driverName;
  final int routeId;
  final String routeNumber;
  final int capacity;
  final int currentPassengers;
  final String crowdednessLevel; // 'seats_available', 'moderately_crowded', 'full'
  final bool isAC;
  final bool isWifi;
  final bool isAccessible;
  final String currentStatus; // 'active', 'inactive', 'break', 'delayed'
  final double lat;
  final double lon;
  final double speed;
  final double direction;
  final int delayMinutes;
  final DateTime lastUpdated;

  Bus({
    required this.id,
    required this.busNumber,
    required this.busName,
    required this.operatorName,
    required this.driverName,
    required this.routeId,
    required this.routeNumber,
    required this.capacity,
    required this.currentPassengers,
    required this.crowdednessLevel,
    required this.isAC,
    required this.isWifi,
    required this.isAccessible,
    required this.currentStatus,
    required this.lat,
    required this.lon,
    required this.speed,
    required this.direction,
    required this.delayMinutes,
    required this.lastUpdated,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] ?? 0,
      busNumber: json['busNumber'] ?? '',
      busName: json['busName'] ?? '',
      operatorName: json['operatorName'] ?? '',
      driverName: json['driverName'] ?? '',
      routeId: json['routeId'] ?? 0,
      routeNumber: json['routeNumber'] ?? '',
      capacity: json['capacity'] ?? 40,
      currentPassengers: json['currentPassengers'] ?? 0,
      crowdednessLevel: json['crowdednessLevel'] ?? 'seats_available',
      isAC: json['isAC'] ?? false,
      isWifi: json['isWifi'] ?? false,
      isAccessible: json['isAccessible'] ?? false,
      currentStatus: json['currentStatus'] ?? 'inactive',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      direction: (json['direction'] as num?)?.toDouble() ?? 0.0,
      delayMinutes: json['delayMinutes'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'busNumber': busNumber,
    'busName': busName,
    'operatorName': operatorName,
    'driverName': driverName,
    'routeId': routeId,
    'routeNumber': routeNumber,
    'capacity': capacity,
    'currentPassengers': currentPassengers,
    'crowdednessLevel': crowdednessLevel,
    'isAC': isAC,
    'isWifi': isWifi,
    'isAccessible': isAccessible,
    'currentStatus': currentStatus,
    'lat': lat,
    'lon': lon,
    'speed': speed,
    'direction': direction,
    'delayMinutes': delayMinutes,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}
