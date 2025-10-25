import 'package:flutter/material.dart';
// 1. Importamos nuestro nuevo archivo para la pantalla de autenticación
import 'screens/auth_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(3, 4, 94, 1.0)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // 2. La 'home' sigue siendo 'AuthScreen', pero ahora
      //    viene del archivo que importamos.
      home: const AuthScreen(),
    );
  }
}

// ¡Y ya está! Todo el código de las pantallas
// se ha movido a otros archivos.
