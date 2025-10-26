import 'package:flutter/material.dart';
import 'screens/auth_screen.dart'; 
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// Importamos el paquete de Autenticación
import 'package:firebase_auth/firebase_auth.dart'; 
// Importamos las opciones que creaste manualmente
import 'firebase_options.dart';

void main() async {
  // Asegura que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase usando tu archivo firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Corre la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        // Usamos el color de tu paleta
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(3, 4, 94, 1.0)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // --- ¡LA LÓGICA DE NAVEGACIÓN PRINCIPAL! ---
      home: StreamBuilder(
        // "Escucha" los cambios de estado de autenticación
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          // Mientras comprueba si hay un usuario logueado...
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un círculo de carga
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si 'snapshot' TIENE DATOS (un objeto User),
          // el usuario ESTÁ logueado.
          if (snapshot.hasData) {
            // Lo mandamos al HomeScreen
            return const HomeScreen();
          }

          // Si NO TIENE DATOS (null),
          // lo mandamos al AuthScreen para que inicie sesión.
          return const AuthScreen();
        },
      ),
    );
  }
}
