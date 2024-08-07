import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forecast Friend',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF234E3D)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forecast Friend'),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Home Page')),
            Center(child: Text('Location Page')),
            AboutPage(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.tealAccent,
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.location_on), text: 'Location'),
              Tab(icon: Icon(Icons.info), text: 'About'),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            'It was built using Flutter and Open Weather Map API and was '
            'developed by Alambuya Chelsea. '
            'Forecast Friend provides you with the latest weather updates in '
            'your current and saved location to help you stay prepared.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
