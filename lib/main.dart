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
            Center(child: Text('About Page')),
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
