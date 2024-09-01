class Town {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final bool currentLocation;
  bool _isSaved;

  Town({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.currentLocation,
    required bool isSaved,
  }) : _isSaved = isSaved;

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

  // Getter for isSaved
  bool get isSaved => _isSaved;

// Setter for isSaved
  void setSaved(bool value) {
    _isSaved = value;
  }

  // Method to convert a Town object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'currentLocation': currentLocation,
      'isSaved': _isSaved,
    };
  }

}
