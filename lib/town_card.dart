import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

class TownCard extends StatelessWidget {
  final String townName;
  final String currentLocation;

  const TownCard({
    super.key,
    required this.townName,
    required this.currentLocation,
  });

  Future<Map<String, dynamic>> fetchWeatherData(String town) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];  // Get the API key from the .env file
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$town&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
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
                  future: fetchWeatherData(townName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final weatherData = snapshot.data!;
                      final temp = weatherData['main']['temp'];
                      final roundedTemp = temp.floor(); // Round down the temperature
                      final weatherDescription =
                      weatherData['weather'][0]['description'];
                      final iconCode = weatherData['weather'][0]['icon'];
                      final gifPath = getGifForWeatherCondition(iconCode); // Get GIF path using the new method
                      return Column(
                        children: [
                          _buildVisualSection('$roundedTemp °C', gifPath),
                          _buildVerbalSection(weatherDescription, townName),
                        ],
                      );
                    } else {
                      return const Text('No data available');
                    }
                  },
                ),
                _buildSection('Hourly Info'),
                _buildSection('Wind, UV, Humidity'),
                _buildSection('Pollen & Driving Conditions'),
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
              townName == currentLocation
                  ? Icons.location_on // Filled icon if town matches current location
                  : Icons
                  .location_on_outlined, // Outlined icon if town doesn't match
              color: Colors.teal,
            ),
            Text(
              townName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            if (townName != currentLocation)
              const ToggleStarButton()
            else
              const Opacity(
                opacity: 0.0, // Makes the icon fully transparent
                child: Icon(
                  Icons.star_border, // Use the outlined star icon
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
          Container(
            width: 135, // Set width for the first container
            height: 120, // Set height for the first container
            child: _buildSingleContainer(title1), // First container
          ),
          const SizedBox(width: 10), // Spacing between the two containers
          Container(
            width: 135, // Set width for the GIF container
            height: 120, // Set height for the GIF container
            child: _buildGifContainer(gifAssetPath), // Second container with GIF
          ),
        ],
      ),
    );
  }

  Widget _buildSingleContainer(String title) {
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

  Widget _buildVerbalSection(String weatherDescription, String town) {
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
          'Current weather in $town: $weatherDescription',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  String getGifForWeatherCondition(String iconCode) {
    switch (iconCode) {
      case '01d': // Clear sky (day)
      case '01n': // Clear sky (night)
        return 'assets/media/sun_gif.gif';
      case '02d': // Few clouds (day)
      case '02n': // Few clouds (night)
        return 'assets/media/cloudy_gif.gif';
      case '03d': // Scattered clouds (day)
      case '03n': // Scattered clouds (night)
      case '04d': // Broken clouds (day)
      case '04n': // Broken clouds (night)
        return 'assets/media/cloudy_gif.gif';
      case '09d': // Shower rain (day)
      case '09n': // Shower rain (night)
      case '10d': // Rain (day)
      case '10n': // Rain (night)
        return 'assets/media/rain_gif.gif';
      case '11d': // Thunderstorm (day)
      case '11n': // Thunderstorm (night)
        return 'assets/media/rain_gif.gif';
      case '13d': // Snow (day)
      case '13n': // Snow (night)
        return 'assets/media/snow_gif.gif';
      case '50d': // Mist (day)
      case '50n': // Mist (night)
        return 'assets/media/mist_gif.gif';
      default: // Default GIF if no match is found
        return 'assets/media/default_gif.gif';
    }
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
      onPressed: _toggleIcon, // Toggle the icon when pressed remove or add city to list
    );
  }
}
