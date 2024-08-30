class Town {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final bool currentLocation;

  Town({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.currentLocation,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      country: json['country'],
      currentLocation: json['currentLocation'],
    );
  }

  @override
  String toString() {
    return 'Town Details:\n'
        'Name: $name\n'
        'Latitude: $latitude\n'
        'Longitude: $longitude\n'
        'Country: $country\n'
        'Current Location: $currentLocation';
  }
}
