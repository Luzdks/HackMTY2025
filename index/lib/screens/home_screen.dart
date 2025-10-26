import 'package:flutter/material.dart';
// ¡Importamos los paquetes de Auth y Firestore!
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables para guardar los datos del usuario
  String _userName = 'Cargando...';
  String _userEmail = '';
  bool _isLoading = true;

  // Obtenemos las instancias de Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 'initState' se llama UNA VEZ cuando se crea la pantalla
  @override
  void initState() {
    super.initState();
    // Llamamos a nuestra función para cargar los datos
    _loadUserData(); 
  }

  // Función asíncrona para buscar los datos en Firestore
  Future<void> _loadUserData() async {
    try {
      // 1. Obtenemos el usuario actual de FirebaseAuth
      final user = _auth.currentUser;
      
      if (user == null) {
        // Si no hay usuario, cerramos sesión (seguridad)
        _signOut(); 
        return;
      }
      
      // 2. Buscamos el documento del usuario en Firestore
      //    usando su 'uid'
      final docSnapshot = await _firestore
          .collection('users') // De la colección 'users'
          .doc(user.uid)      // El documento con este ID
          .get();              // ¡Tráelo!

      // 3. Comprobamos si el documento existe
      if (docSnapshot.exists) {
        // Si existe, actualizamos la UI con los datos
        setState(() {
          _userName = docSnapshot.data()?['name'] ?? 'Usuario';
          _userEmail = docSnapshot.data()?['email'] ?? 'Sin email';
          _isLoading = false;
        });
      } else {
        // Si no existe (raro, pero posible)
        setState(() {
          _userName = 'Usuario (Sin datos)';
          _userEmail = user.email ?? 'Sin email'; 
          _isLoading = false;
        });
      }

    } catch (e) {
      print('Error al cargar datos en HomeScreen: $e');
      setState(() {
        _userName = 'Error al cargar';
        _isLoading = false;
      });
    }
  }

  // --- FUNCIÓN PARA CERRAR SESIÓN ---
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // El 'StreamBuilder' en main.dart nos regresará al Login
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión.'), 
        backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Principal'),
        backgroundColor: Color.fromRGBO(3, 4, 94, 1.0),
        foregroundColor: Colors.white,
        actions: [
          // --- BOTÓN DE CERRAR SESIÓN ---
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut, // Llama a nuestra función
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Container(
        // Mismo fondo de gradiente
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
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¡Bienvenido,',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  // ¡Muestra el nombre que cargó desde Firestore!
                  Text(
                    _userName, 
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Muestra el email
                  Text(
                    _userEmail, 
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}