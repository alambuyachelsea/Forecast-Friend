class Town {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final bool currentLocation;
  final bool isSaved;

  Town({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.currentLocation,
    required this.isSaved,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      country: json['country'],
      currentLocation: json['currentLocation'],
      isSaved: json['isSaved'],
    );
  }

  // Method to convert a Town object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'currentLocation': currentLocation,
      'isSaved': isSaved,
    };
}

  @override
  String toString() {
    return 'Town Details:\n'
        'Name: $name\n'
        'Latitude: $latitude\n'
        'Longitude: $longitude\n'
        'Country: $country\n'
        'Current Location: $currentLocation\n'
        'Starred: $isSaved';
  }
}
