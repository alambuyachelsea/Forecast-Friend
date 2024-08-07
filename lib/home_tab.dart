import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:carousel_slider/carousel_slider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> towns = [];

  @override
  void initState() {
    super.initState();
    loadTowns();
  }

  Future<void> loadTowns() async {
    final String response = await rootBundle.loadString('assets/towns.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      towns = data.map((town) => town['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return towns.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Scrollbar(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 700, // Set the height of the carousel
          enableInfiniteScroll: false, // Disable infinite scroll
          viewportFraction: 0.9, // Adjust this value to fill more space
          autoPlay: false, // Disable autoplay
          enlargeCenterPage: true,
        ),
        items: towns.map((town) {
          return Builder(
            builder: (BuildContext context) {
              return Align(
                alignment: Alignment.topCenter, // Align the card to the top
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Set the width of each card
                    height: 660, // Set the height of each card
                    margin: const EdgeInsets.only(top: 0.0), // Adjust the top margin
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        town,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
