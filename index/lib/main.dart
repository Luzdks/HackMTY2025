import 'package:flutter/material.dart';
import 'screens/auth_screen.dart'; 
import 'screens/home_screen.dart'; // Ahora es el "Shell"
import 'package:firebase_core/firebase_core.dart';
// Importamos el paquete de Autenticación
import 'package:firebase_auth/firebase_auth.dart'; 
// Importamos las opciones que creaste manualmente
import 'firebase_options.dart';
// ¡Importamos nuestra paleta!
import 'theme/app_colors.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Financiera',
      // --- ¡NUEVO TEMA APLICADO! ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mediumBlue, // Color principal
          primary: AppColors.mediumBlue,
          secondary: AppColors.cyan, // Color de acento
          //background: AppColors.almostWhiteBlue, // Fondo claro de la app
          surface: AppColors.white, // Color de las tarjetas
        ),
        scaffoldBackgroundColor: AppColors.almostWhiteBlue, // Fondo general
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkestBlue, // Barra de navegación oscura
          foregroundColor: AppColors.white, // Texto de la barra blanco
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: AppColors.paleBlue, width: 1.5),
           ),
           enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: AppColors.paleBlue, width: 1.5),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: AppColors.mediumBlue, width: 2),
           ),
        ),
        useMaterial3: true,
      ),
      // -----------------------------
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // Sigue apuntando a HomeScreen, que ahora es
            // nuestro "Navigation Hub"
            return const HomeScreen(); 
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
