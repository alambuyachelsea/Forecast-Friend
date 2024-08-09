import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'town_card.dart';  // Import the TownCard widget

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> townNames = []; // List to store the nearest city and towns from JSON
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTownsAndFetchNearestCity();
  }

  Future<void> loadTownsAndFetchNearestCity() async {
    try {
      // Load towns from JSON file
      List<String> towns = await _loadTownsFromJson();
      print('Loaded towns from JSON: $towns');

      // Fetch nearest city
      Position position = await _getCurrentLocation();
      print('Current Position: ${position.latitude}, ${position.longitude}');
      String nearestCity = await _findNearestCity(position);
      print('Nearest City: $nearestCity');

      // Combine nearest city with the towns from the JSON file
      setState(() {
        townNames = [nearestCity, ...towns];
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        townNames = ['Error finding nearest city or loading towns'];
        isLoading = false;
      });
    }
  }

  // Load towns from the JSON file
  Future<List<String>> _loadTownsFromJson() async {
    final String response = await rootBundle.loadString('assets/saved_towns.json');
    final data = json.decode(response);
    List<String> towns = List<String>.from(data['towns']);
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
    
  }

  // Find the nearest city using Google Places API
  Future<String> _findNearestCity(Position position) async {
    final lat = position.latitude;
    final lon = position.longitude;
    const apiKey = 'AIzaSyA69a-cGEZ16aiRkYjLfIBncs_QriDKiok'; // Replace with your API key

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
        itemCount: townNames.length,
        controller: PageController(viewportFraction: 0.8),
        itemBuilder: (context, index) {
          return TownCard(townName: townNames[index]);
        },
      ),
    );
  }
}
