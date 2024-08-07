import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String nearestCity = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNearestCity();
  }

  Future<void> fetchNearestCity() async {
    try {
      Position position = await _getCurrentLocation();
      print('Current Position: ${position.latitude}, ${position.longitude}');
      final city = await _findNearestCity(position);
      setState(() {
        nearestCity = city;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        nearestCity = 'Error finding city';
        isLoading = false;
      });
    }
  }

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

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

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
        : Center(
      child: Text(
        'Nearest City: $nearestCity',
        style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
