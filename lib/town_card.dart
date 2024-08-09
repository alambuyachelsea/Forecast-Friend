import 'package:flutter/material.dart';

class TownCard extends StatelessWidget {
  final String townName;
  final String currentLocation;

  const TownCard({super.key, required this.townName, required this.currentLocation});

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
                _buildSection('Visual Summary'),
                _buildSection('Verbal Summary'),
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
                  : Icons.location_on_outlined, // Outlined icon if town doesn't match
              color: Colors.teal,
            ),
            Text(
              townName,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Visibility(
              visible: townName != currentLocation, // Icon is visible only if townName doesn't match currentLocation
              child: const Icon(
                Icons.star,
                color: Colors.yellow,
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
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
}
