import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv

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
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$bassedUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = json.decode(response.body)['predictions'];
        });
      } else {}
      throw Exception("Fail to load");
    } catch (e) {
      print(e.toString());
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
              visible: searchController.text.isEmpty ? false : true,
              child: Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listOfLocation.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {},
                        child: ListTile(
                          title:  Text(
                            listOfLocation[index]["description"],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}