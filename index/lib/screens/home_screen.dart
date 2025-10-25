import 'package:flutter/material.dart';

// -------------------------------------------------------------------
// PANTALLA DE INICIO (Después del Login)
// (Este es el mismo código que tenías antes, pero en su propio archivo)
// -------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Principal'),
        backgroundColor: Color.fromRGBO(3, 4, 94, 1.0),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(2, 62, 138, 1.0),
              Color.fromRGBO(0, 119, 182, 1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            '¡Bienvenido, $userName!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
