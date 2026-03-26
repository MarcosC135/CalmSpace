import 'package:flutter/material.dart';
import 'screens/register_screen.dart'; // Llama a tu pantalla de registro

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí está el MaterialApp que faltaba
    return MaterialApp(
      title: 'CalmSpace',
      debugShowCheckedModeBanner: false, // Esto quita la rayita roja de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RegisterScreen(), // Tu pantalla de registro
    );
  }
}
