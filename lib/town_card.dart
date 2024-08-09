import 'package:flutter/material.dart';

class TownCard extends StatelessWidget {
  final String townName;

  const TownCard({Key? key, required this.townName}) : super(key: key);

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
                _buildSection('Location'),
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
