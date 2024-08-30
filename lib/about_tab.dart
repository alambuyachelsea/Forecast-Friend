import 'package:flutter/material.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'About Forecast Friend',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'This is an app developed for the course 1DV535 at Linneaus University. '
            'It was built using Flutter  APIs from Open Weather Map and Google'
            ' Places. '
            'Developed by Alambuya Chelsea. '
            'Forecast Friend provides you with the latest weather updates in '
            'your current and saved location to help you stay prepared. '
            ' You can additionally search for other areas to add to your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
