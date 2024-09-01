import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_assist/town_card.dart';
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
      String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$baseUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('here');
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Function to handle click action on list items
  void _onLocationSelected(String description) {
    // Fetch latitude and longitude based on the selected place
    _fetchLatLong(description).then((town) {
      if (town != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TownDetailsPage(town: town), // Replace with your existing class
          ),
        );
      }
    });
  }

  Future<Town?> _fetchLatLong(String description) async {
    final apiKey = dotenv.env['PLACES_API_KEY']; // Fetch the API key from .env file

    print('des');
    print(description);

    try {
      String baseUrl =
          "https://maps.googleapis.com/maps/api/geocode/json";
      String request =
          '$baseUrl?address=$description&key=$apiKey';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      print('reponse');
      print(response);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        var result = data['results'][0];
        var location = result['geometry']['location'];
        return Town(
          name: description,
          latitude: location['lat'],
          longitude: location['lng'],
          country: result['formatted_address'], // Use formatted address as a placeholder for the country
          currentLocation: false,
          isSaved: false,
        );
      } else {
        print('Failed to get location data.');
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



// Replace `TownDetailsPage` with the name of your existing class
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
