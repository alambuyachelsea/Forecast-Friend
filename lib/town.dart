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

  // Method to write the details of the town to a string
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
