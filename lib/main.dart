import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/carbon_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarbonService(),
      child: const EcoBotApp(),
    ),
  );
}

class EcoBotApp extends StatelessWidget {
  const EcoBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoBot',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}