import 'package:flutter/material.dart';
import 'package:to_do_project/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Paleta de cores que você já usa
  static const _primary = Color.fromARGB(255, 216, 21, 7);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: _primary,
          secondary: _primary,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _primary,
          selectionColor: _primary,
          selectionHandleColor: _primary,
        ),
      ),

      // ⬇⬇⬇ AQUI você escolhe qual tela é a primeira
      home: const Login(), // se quiser que o Login seja a primeira
      // home: const Cadastro(), // se quiser que o Cadastro seja a primeira
      // home: const HomePage(), // se quiser que a Home seja a primeira
    );
  }
}
