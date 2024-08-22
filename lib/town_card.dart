import 'package:flutter/material.dart';

class TownCard extends StatelessWidget {
  final String townName;
  final String currentLocation;

  const TownCard(
      {super.key, required this.townName, required this.currentLocation});

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
                _buildVisualSection('25 °C', 'assets/media/sun_gif.gif'),
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
                  ? Icons
                      .location_on // Filled icon if town matches current location
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
          ],  // Children
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
