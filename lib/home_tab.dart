import 'package:flutter/material.dart';
import 'package:forecast_friend/town.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:shared_preferences/shared_preferences.dart';
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
      List<Town> loadedTowns = await _loadTownsFromSharedPreferences();

      // Fetch nearest city
      Position position = await _getCurrentLocation();
      String nearestCity = await _findNearestCity(position);

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
              isSaved: false),
          ...loadedTowns
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        towns = [
          Town(
              name: 'Error',
              latitude: 0,
              longitude: 0,
              country: 'Unknown',
              currentLocation: false,
              isSaved: false)
        ];
        isLoading = false;
      });
    }

    setState(() {});
  }

  Future<List<Town>> _loadTownsFromSharedPreferences() async {
    List<Town> towns = [];

    try {
      // Obtain the SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the JSON string from SharedPreferences
      String? jsonString = prefs.getString('townsList');

      if (jsonString != null) {
        // Decode the JSON string to a Map<String, dynamic>
        final data = jsonDecode(jsonString);

        try {
          // Use a for loop to iterate over the JSON list
          for (var json in data) {
            // Convert each JSON map to a Town object
            Town town = Town.fromJson(json);
            // Add the Town object to the list
            towns.add(town);
          }
        } catch (e) {
          print("Error parsing town list: $e");
        }
        return towns;
      } else {
        // Return an empty list if no data is found in SharedPreferences
        return [];
      }
    } catch (e) {
      print("Error here: $e");
    }
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
    final apiKey =
        dotenv.env['PLACES_API_KEY']; // Fetch the API key from .env file

    if (apiKey == null) {
      throw Exception('API key not found in .env file');
    }

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lon&radius=50000&type=locality&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['name'];
      } else {
        return 'No city found';
      }
    } else {
      throw Exception('Failed to load nearest city');
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});

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
