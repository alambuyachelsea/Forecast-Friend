import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'about_tab.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import the flutter_dotenv package

Future<void> main() async {
  await dotenv.load();
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
            HomeTab(),
            SearchTab(),
            AboutTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.tealAccent,
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.info), text: 'About'),
            ],
          ),
        ),
      ),
    );
  }
}
