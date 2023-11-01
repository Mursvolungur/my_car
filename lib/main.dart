import 'package:flutter/material.dart';
import 'package:my_car/widgets/lista_sostituzioni.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

final String appTitle = 'My Car';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Car',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue.shade900,
          surface: const Color.fromARGB(255, 50, 107, 200)
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            appTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )
          ),
        ),
        body: const ListaSostituzioni(),
      )
    );
  }
}