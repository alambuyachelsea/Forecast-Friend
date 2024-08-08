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
          height: 700,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              townName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
