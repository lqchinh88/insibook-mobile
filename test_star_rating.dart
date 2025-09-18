import 'package:flutter/material.dart';
import 'lib/widgets/star_rating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Star Rating Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StarRating(
                rating: 3.75,
                reviewCount: 1543,
                size: 12,
                fontSize: 8,
              ),
              SizedBox(height: 20),
              StarRating(
                rating: 4.2,
                reviewCount: 10770,
                size: 16,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}