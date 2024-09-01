import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_assist/town_card.dart'; // Import your TownCard widget
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'town.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab> {
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
  }

  _onChange() {
    placeSuggestion(searchController.text);
  }

  void placeSuggestion(String input) async {
    final apiKey = dotenv.env['PLACES_API_KEY']; // Fetch the API key from .env file

    try {
      String baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = '$baseUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        print('Failed to load suggestions. Status code: ${response.statusCode}');
        throw Exception("Failed to load suggestions");
      }
    } catch (e) {
      print('Error in placeSuggestion: $e');
    }
  }

  void _onLocationSelected(String description) {
    // Fetch latitude and longitude based on the selected place
    _fetchLatLong(description).then((town) {
      if (town != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TownDetailsPage(town: town),
          ),
        );
      }
    });
  }

  Map<String, String> splitCityCountry(String input) {
    // Split the string by comma
    List<String> parts = input.split(',');

    // Check if the parts list has exactly two elements
    if (parts.length == 2) {
      String city = parts[0].trim();
      String country = parts[1].trim();

      // Return a map with separate city and country
      return {'city': city, 'country': country};
    } else {
      // Handle cases where the input string is not in the expected format
      return {'error': 'Invalid format'};
    }
  }

  String formatCityCountry(String input) {
    // Split the string by comma
    List<String> parts = input.split(',');

    // Check if the parts list has exactly two elements
    if (parts.length == 2) {
      String city = parts[0].trim();
      String country = parts[1].trim();

      // Return the formatted string with '+' instead of ','
      return '$city,+$country';
    } else {
      // Handle cases where the input string is not in the expected format
      return 'Invalid format';
    }
  }

  Future<Town?> _fetchLatLong(String description) async {

    final apiKey = dotenv.env['GEOCODE_API_KEY'];

    final combinedLocation = formatCityCountry(description);

    try {
      String baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
      String request = '$baseUrl?address=${Uri.encodeComponent(combinedLocation)}&key=$apiKey';
      var response = await http.get(Uri.parse(request));



      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          var result = data['results'][0];
          var location = result['geometry']['location'];

          Map<String, String>  splitLocation =  splitCityCountry(description);

          return Town(
            name: ('${splitLocation['city']}'),
            latitude: location['lat'],
            longitude: location['lng'],
            country: ('${splitLocation['country']}'),
            currentLocation: false,
            isSaved: false,
          );
        } else {
          print('No results found.');
          return null;
        }
      } else {
        print('Failed to get location data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search ...",
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            Visibility(
              visible: searchController.text.isNotEmpty,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listOfLocation.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _onLocationSelected(listOfLocation[index]["description"]);
                      },
                      child: ListTile(
                        title: Text(
                          listOfLocation[index]["description"],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Assuming you have a TownCard widget defined in town_card.dart
class TownDetailsPage extends StatelessWidget {
  final Town town;

  const TownDetailsPage({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Town Details'),
      ),
      body: Center(
        child: TownCard(
          town: town,
          isCurrentLocation: town.currentLocation,
        ),
      ),
    );
  }
}
