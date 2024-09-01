import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'town.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TownCard extends StatelessWidget {
  final Town town;
  final bool isCurrentLocation;

  const TownCard({
    super.key,
    required this.town,
    required this.isCurrentLocation,
  });

  // Fetch current weather data from OpenWeatherMap API
  Future<Map<String, dynamic>> fetchCurrentWeatherData(String townName) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY']; // Get the API key from the .env file
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$townName&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetches forecast data from open weather
  Future<Map<String, dynamic>> fetchForecastData(String townName) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$townName&appid=$apiKey&units=metric'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hourly forecast data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 900, // Fixed height of the card
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationSection(),
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchCurrentWeatherData(town.name), // Location area
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) { // Weather data variables
                      final weatherData = snapshot.data!;
                      final temp = weatherData['main']['temp'];
                      final tempMin = weatherData['main']['temp_min'];
                      final tempMax = weatherData['main']['temp_max'];
                      final roundedTemp = temp.floor();
                      final roundedTempMin = tempMin.floor();
                      final roundedTempMax = tempMax.floor();
                      final weatherDescription = weatherData['weather'][0]['description'];
                      final iconCode = weatherData['weather'][0]['icon'];
                      final gifPath = getGifForWeatherCondition(iconCode);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVisualSection(roundedTemp, roundedTempMin, roundedTempMax, gifPath),
                          Row( // Shows the days max, current and min temp plus visual representation of current conditions
                            children: [
                              Expanded( // A short summary of current conditions
                                child: _buildVerbalSection(weatherDescription, town.name),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FutureBuilder<double>( // Shows the current uv index
                                  future: fetchUVIndex(town.latitude, town.longitude),
                                  builder: (context, uvSnapshot) {
                                    if (uvSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (uvSnapshot.hasError) {
                                      return Center(child: Text('Error loading UV index: ${uvSnapshot.error}'));
                                    } else if (uvSnapshot.hasData) {
                                      return _buildUVIndexSection(uvSnapshot.data!);
                                    } else {
                                      return const Center(child: Text('No UV data available'));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildVisibilityPressureSection(weatherData), // Shows visibility and air pressure
                          _buildWindHumiditySection(weatherData), // Shows humidity and wind speed

                          FutureBuilder<Map<String, dynamic>>( // Shows 3-hour interval forecast
                            future: fetchForecastData(town.name),
                            builder: (context, hourlySnapshot) {
                              if (hourlySnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (hourlySnapshot.hasError) {
                                return Center(child: Text('Error: ${hourlySnapshot.error}'));
                              } else if (hourlySnapshot.hasData) {
                                final hourlyData = hourlySnapshot.data!['list'];
                                final hourlyForecastData = hourlyData.take(8).toList();
                                return _buildHourlyForecastSection(hourlyForecastData);
                              } else {
                                return const Center(child: Text('No hourly forecast data available'));
                              }
                            },
                          ),
                          FutureBuilder<Map<String, dynamic>>( // Shows 5 day forecast
                            future: fetchForecastData(town.name),
                            builder: (context, forecastSnapshot) {
                              if (forecastSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (forecastSnapshot.hasError) {
                                return Center(child: Text('Error: ${forecastSnapshot.error}'));
                              } else if (forecastSnapshot.hasData) {
                                final forecastData = forecastSnapshot.data!;
                                return _build5DayForecastSection(forecastData);
                              } else {
                                return const Center(child: Text('No 5-day forecast data available'));
                              }
                            },
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: Text('No data available'));
                    }
                  },
                ),
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
              isCurrentLocation ? Icons.location_on : Icons.location_on_outlined,
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
              ToggleStarButton(
                town: town,
                isInitiallySaved: town.isSaved,

              )
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


  Widget _buildVisualSection(int temp, int tempMin, int tempMax, String gifAssetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 145,
            height: 120,
            child: _buildTempSection(temp, tempMin, tempMax), // Temperature container
          ),
          const SizedBox(width: 10), // Spacing between the two containers
          SizedBox(
            width: 140,
            height: 120,
            child: _buildGifContainer(gifAssetPath), // Container with GIF
          ),
        ],
      ),
    );
  }

  Widget _buildTempSection(int temp, int tempMin, int tempMax) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal, width: 2),
        color: Colors.teal.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Max: $tempMax °C',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 5), // Spacing between temperatures
          Text(
            '$temp °C',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Text(
            'Min: $tempMin °C',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.teal,
            ),
          ),
        ],
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
      child: Image.asset(
        gifAssetPath,
        fit: BoxFit.cover,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Current Conditions',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.teal,
              ),
            ),
            Text(
              weatherCondition,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
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
                      fontSize: 12.0,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${windSpeed.toStringAsFixed(1)} m/s',
                    style: const TextStyle(
                      fontSize: 14.0,
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
                      fontSize: 12.0,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${humidity.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14.0,
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
    final visibility = weatherData['visibility'] / 1000;
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
                      fontSize: 12.0,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${visibility.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
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
                      fontSize: 12.0,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    '${pressure.toString()} hPa',
                    style: const TextStyle(
                      fontSize: 14.0,
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

  Future<double> fetchUVIndex(double lat, double lon) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/uvi?lat=$lat&lon=$lon&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['value']?.toDouble() ?? 0.0; // Return the UV index value or 0.0 if not found
    } else {
      throw Exception('Failed to load UV index data');
    }
  }

  Widget _buildUVIndexSection(double uvIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
              'UV Index',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.teal,
              ),
            ),
            Text(
              uvIndex.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastSection(List<dynamic> hourlyData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 2),
          color: Colors.teal.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyData.length,
                itemBuilder: (context, index) {
                  final hourData = hourlyData[index] as Map<String, dynamic>;
                  final time = DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);
                  final temp = hourData['main']['temp'];
                  final roundedTemp = temp.floor();
                  final weatherIcon = hourData['weather'][0]['icon'] as String;

                  return Container(
                    width: 100,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal, width: 2),
                      color: Colors.teal.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${time.hour}:00',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Image.network(
                          'http://openweathermap.org/img/wn/$weatherIcon.png',
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          '$roundedTemp°C',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _build5DayForecastSection(Map<String, dynamic> forecastData) {
    // Ensure forecastData contains 'list' and it's a List
    if (forecastData['list'] is List) {
      final dailyForecasts = forecastData['list'] as List<dynamic>;

      // Filter to get daily summaries
      final filteredForecasts = dailyForecasts.where((entry) {
        return entry['dt_txt'] != null && entry['dt_txt'].contains('12:00:00');
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.teal, width: 2),
            color: Colors.teal.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: filteredForecasts.map<Widget>((dailyData) {
                  final date = DateTime.fromMillisecondsSinceEpoch(dailyData['dt'] * 1000);
                  final temp = dailyData['main']['temp'];
                  final weatherIcon = dailyData['weather'][0]['icon'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          _getDayName(date.weekday),
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          'http://openweathermap.org/img/wn/$weatherIcon.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$temp°C',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('No valid forecast data available'));
    }
  }

  // Helper function to get the day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  // I know hardcoding isn't the best but i'm on a deadline here
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

// Weather description is in lower case
extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// save the list of towns to SharedPreferences
Future<void> saveTownsToSharedPreferences(List<Town> towns) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Convert each Town object in the list to JSON format
    List<Map<String, dynamic>> jsonList = towns.map((town) => town.toJson()).toList();

    // Convert the list of maps to a JSON string
    String jsonString = jsonEncode(jsonList);

    // Save the JSON string to SharedPreferences
    await prefs.setString('townsList', jsonString);

    print("Towns saved successfully.");
  } catch (e) {
    print("Error saving towns to SharedPreferences: $e");
  }
}

Future<List<Town>> _loadTownsFromSharedPreferences() async {

  List<Town> towns = [];

  try {
    // Obtain the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences using townsList key
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


void saveTown(Town townToSave) async {
  townToSave.setSaved(true);

  List<Town> towns = await _loadTownsFromSharedPreferences();

  towns.add(townToSave);
  // save to shared preferences
  await saveTownsToSharedPreferences(towns);

}

// Remove town and save
Future<void> removeTown(Town townToRemove) async {

  townToRemove.setSaved(false);
  List<Town> towns = await _loadTownsFromSharedPreferences();

  // Filter out the town to remove
  towns.removeWhere((town) => town.name == townToRemove.name);
  await saveTownsToSharedPreferences(towns);
}

// Star button to save town card
class ToggleStarButton extends StatefulWidget {
  final Town town;
  final bool isInitiallySaved;

  const ToggleStarButton({super.key, required this.town, this.isInitiallySaved = false});

  @override
  _ToggleStarButtonState createState() => _ToggleStarButtonState();
}

class _ToggleStarButtonState extends State<ToggleStarButton> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isInitiallySaved; // Initialize with the passed value
  }

  void _toggleSaved() async {
    setState(() {
      _isSaved = !_isSaved;
    });

    if (_isSaved) {
      saveTown(widget.town); // Save the town to the JSON file
    } else {
      removeTown(widget.town); // Remove the town from the JSON file

    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSaved ? Icons.star : Icons.star_border,
        color: _isSaved ? Colors.yellow : Colors.grey,
      ),
      onPressed: _toggleSaved,
    );
  }
}
