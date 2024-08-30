import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'town_card.dart'; // Make sure this import matches the location of your TownCard file

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Town> towns = []; // List to store the towns from JSON
  String currentLocation = ''; // To store the nearest city name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTownsAndFetchNearestCity();
  }

  Future<void> loadTownsAndFetchNearestCity() async {
    try {
      // Load towns from JSON file
      List<Town> loadedTowns = await _loadTownsFromJson();
      print('Loaded towns from JSON: $loadedTowns');

      // Fetch nearest city
      Position position = await _getCurrentLocation();
      print('Current Position: ${position.latitude}, ${position.longitude}');
      String nearestCity = await _findNearestCity(position);
      print('Nearest City: $nearestCity');

      // Combine nearest city with the towns from the JSON file
      setState(() {
        currentLocation = nearestCity;
        towns = [
          Town(
            name: nearestCity,
            latitude: position.latitude,
            longitude: position.longitude,
            country: 'Unknown', // Update this as needed
            currentLocation: true,
          ),
          ...loadedTowns
        ];
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        towns = [
          Town(
            name: 'Error finding nearest city or loading towns',
            latitude: 0,
            longitude: 0,
            country: 'Unknown',
            currentLocation: false,
          )
        ];
        isLoading = false;
      });
    }
  }

  // Load towns from the JSON file
  Future<List<Town>> _loadTownsFromJson() async {
    final String response = await rootBundle.loadString('assets/saved_towns.json');
    final data = json.decode(response);
    List<dynamic> townList = data['towns'];

    // Convert the JSON list to a List of Town objects
    List<Town> towns = townList.map((townJson) => Town.fromJson(townJson)).toList();
    return towns;
  }

  // Get the current location of the device
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Find the nearest city using Google Places API
  Future<String> _findNearestCity(Position position) async {
    final lat = position.latitude;
    final lon = position.longitude;
    final apiKey = dotenv.env['LOCATIONS_API_KEY']; // Fetch the API key from .env file

    if (apiKey == null) {
      throw Exception('API key not found in .env file');
    }

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lon&radius=50000&type=locality&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['name'];
      } else {
        return 'No city found';
      }
    } else {
      print('Failed to load nearest city. Status code: ${response.statusCode}');
      throw Exception('Failed to load nearest city');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: PageView.builder(
        itemCount: towns.length,
        controller: PageController(viewportFraction: 0.8),
        itemBuilder: (context, index) {
          final town = towns[index];
          return TownCard(
            town: town,
            isCurrentLocation: town.name == currentLocation,
          );
        },
      ),
    );
  }
}
