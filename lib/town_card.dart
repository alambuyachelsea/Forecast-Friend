import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the Town model class
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

  // Factory method to create a Town object from JSON
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

// Define the TownCard widget
class TownCard extends StatelessWidget {
  final Town town;
  final bool isCurrentLocation;

  const TownCard({
    super.key,
    required this.town,
    required this.isCurrentLocation,
  });

  // Fetch weather data from OpenWeatherMap API
  Future<Map<String, dynamic>> fetchWeatherData(String townName) async {
    final apiKey = dotenv
        .env['OPEN_WEATHER_API_KEY']; // Get the API key from the .env file
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$townName&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Load towns from JSON file
  Future<List<Town>> loadTownsFromJson() async {
    final String response =
        await rootBundle.loadString('assets/saved_towns.json');
    final data = json.decode(response);

    // Ensure the JSON data is correctly structured
    List<Town> towns =
        List<Town>.from(data['towns'].map((town) => Town.fromJson(town)));

    return towns;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 900, // Fixed height of the card
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationSection(),
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchWeatherData(town.name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final weatherData = snapshot.data!;
                      final temp = weatherData['main']['temp'];
                      final roundedTemp = temp.floor(); // Round down the temperature
                      final weatherDescription = weatherData['weather'][0]['description'];
                      final iconCode = weatherData['weather'][0]['icon'];
                      final gifPath = getGifForWeatherCondition(iconCode); // Get GIF path using the new method

                      return Column(
                        children: [
                          _buildVisualSection('$roundedTemp °C', gifPath),
                          _buildVerbalSection(weatherDescription, town.name),
                          _buildWindHumiditySection(weatherData),
                          _buildVisibilityPressureSection(weatherData),
                        ],
                      );
                    } else {
                      return const Text('No data available');
                    }
                  },
                ),
                _buildSection('Hourly Info'),
                _buildSection('Pollen & UV'),
                _buildSection('Weekly Forecast'),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 2),
          color: Colors.teal.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              isCurrentLocation
                  ? Icons.location_on
                  : Icons.location_on_outlined,
              color: Colors.teal,
            ),
            Text(
              town.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            if (!isCurrentLocation)
              const ToggleStarButton()
            else
              const Opacity(
                opacity: 0.0, // Makes the icon fully transparent
                child: Icon(
                  Icons.star_border,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualSection(String title1, String gifAssetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 135, // Set width for the first container
            height: 120, // Set height for the first container
            child: _buildTempSection(title1), // First container
          ),
          const SizedBox(width: 10), // Spacing between the two containers
          SizedBox(
            width: 135, // Set width for the GIF container
            height: 120, // Set height for the GIF container
            child:
                _buildGifContainer(gifAssetPath), // Second container with GIF
          ),
        ],
      ),
    );
  }

  Widget _buildTempSection(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal, width: 2),
        color: Colors.teal.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildGifContainer(String gifAssetPath) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal, width: 2),
        color: Colors.teal.withOpacity(0.1),
      ),
      child: Center(
        child: Image.asset(
          gifAssetPath, // Path to your GIF asset
          fit: BoxFit.cover, // Adjust the GIF to fit the container
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 2),
          color: Colors.teal.withOpacity(0.1),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildVerbalSection(String weatherDescription, String townName) {
    String weatherCondition = weatherDescription.capitalize();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 2),
          color: Colors.teal.withOpacity(0.1),
        ),
        child: Text(
          'Current Conditions: $weatherCondition',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildWindHumiditySection(Map<String, dynamic> weatherData) {
    final windSpeed = weatherData['wind']['speed'];
    final humidity = weatherData['main']['humidity'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.teal.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Wind Speed',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${windSpeed.toStringAsFixed(1)} m/s',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10), // Spacing between the two containers
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.teal.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Humidity',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${humidity.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityPressureSection(Map<String, dynamic> weatherData) {
    final visibility = weatherData['visibility'] / 1000; // Convert meters to kilometers
    final pressure = weatherData['main']['pressure'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.teal.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Visibility',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${visibility.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10), // Spacing between the containers
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.teal.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pressure',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${pressure.toString()} hPa',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }




  String getGifForWeatherCondition(String iconCode) {
    switch (iconCode) {
      case '01d': // Clear sky (day)
        return 'assets/media/sun_gif.gif';
      case '01n': // Clear sky (night)
        return 'assets/media/clear_night.gif';
      case '02d': // Few clouds (day)
      case '03d': // Scattered clouds (day)
      case '04d': // Broken clouds (day)
        return 'assets/media/cloudy_gif.gif';
      case '02n': // Few clouds (night)
      case '03n': // Scattered clouds (night)
      case '04n': // Broken clouds (night)
        return 'assets/media/night_clouds.gif';
      case '09d': // Shower rain (day)
      case '11d': // Thunderstorm (day)
      case '10d': // Rain (day)
        return 'assets/media/rain_gif.gif';
      case '09n': // Shower rain (night)
      case '11n': // Thunderstorm (night)
      case '10n': // Rain (night)
        return 'assets/media/night_rain.gif';
      case '13d': // Snow (day)
        return 'assets/media/snow_gif.gif';
      case '13n': // Snow (night)
        return 'assets/media/night_snow.gif';
      case '50d': // Mist (day)
        return 'assets/media/fog_gif.gif';
      case '50n': // Mist (night)
        return 'assets/media/night_fog.gif';
      default: // Default GIF if no match is found
        return 'assets/media/default_gif.gif';
    }
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class ToggleStarButton extends StatefulWidget {
  const ToggleStarButton({super.key});

  @override
  _ToggleStarButtonState createState() => _ToggleStarButtonState();
}

class _ToggleStarButtonState extends State<ToggleStarButton> {
  bool _isFilled = true; // Tracks whether the icon is filled or outlined

  void _toggleIcon() {
    setState(() {
      _isFilled = !_isFilled; // Toggle the state between filled and outlined
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFilled
            ? Icons.star
            : Icons.star_border, // Use filled or outlined icon based on state
        color: Colors.yellow,
      ),
      onPressed:
          _toggleIcon, // Toggle the icon when pressed remove or add city to list
    );
  }
}
