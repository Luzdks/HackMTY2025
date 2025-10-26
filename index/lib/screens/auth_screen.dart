// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// Importamos el paquete de Autenticación
import 'package:firebase_auth/firebase_auth.dart';
// Importamos el paquete de Base de Datos
import 'package:cloud_firestore/cloud_firestore.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginView = true;
  bool _isLoading = false; 

  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Obtenemos la instancia de FirebaseAuth
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función para cambiar entre vista de Login y Registro
  void _toggleView() {
    if (_isLoading) return; 
    setState(() {
      _isLoginView = !_isLoginView;
    });
  }

  // --- ¡AQUÍ ESTÁ LA LÓGICA DE CREAR CUENTA Y GUARDAR! ---
  void _submit() async {
    // 1. Obtenemos los valores de los campos
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // 2. Validaciones simples
    if (email.isEmpty || password.isEmpty || (!_isLoginView && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos.'), 
        backgroundColor: Colors.red),
      );
      return; 
    }
    
    // 3. Mostramos el círculo de "cargando"
    setState(() { _isLoading = true; });

    try {
      // Si estamos en la vista de "Login"
      if (_isLoginView) {
        
        // --- 4a. LÓGICA DE LOGIN ---
        await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password,
        );
        // (Si esto es exitoso, el 'StreamBuilder' en main.dart
        //  nos navegará automáticamente)

      } else {
        
        // --- 4b. LÓGICA DE REGISTRO ---
        
        // Primero, creamos el usuario en FIREBASE AUTH
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password,
        );
        
        // 5. ¡¡GUARDAR DATOS EN FIRESTORE!!
        // Obtenemos el UID (ID único) del usuario
        final uid = userCredential.user!.uid;

        // Creamos el mapa (JSON) de los datos que queremos guardar
        final userData = {
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(), // Guarda la fecha de creación
        };
        
        // Ahora, vamos a Firestore, a la colección 'users',
        // creamos un documento con el 'uid' del usuario,
        // y le guardamos los datos.
        await FirebaseFirestore.instance
            .collection('users') // La "carpeta"
            .doc(uid)           // El "archivo" (nombrado como el ID)
            .set(userData);      // Los datos
        
        // (Si esto es exitoso, el 'StreamBuilder' en main.dart
        //  nos navegará automáticamente)
      }
      
      if (!mounted) return;

    } on FirebaseAuthException catch (e) {
      // --- MANEJO DE ERRORES DE FIREBASE ---
      //print('Error de FirebaseAuth: ${e.code}');
      String message = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil (6+ caracteres).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ese correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es válido.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS' || e.code == 'wrong-password' || e.code == 'user-not-found') {
        message = 'Credenciales incorrectas.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red)
      );
      // Si hubo un error, quitamos el "cargando"
      setState(() { _isLoading = false; }); 

    } catch (e) {
      // Manejo de errores generales
      //print('Error en _submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.'), 
        backgroundColor: Colors.red)
      );
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginView ? 'Iniciar Sesión' : 'Crear Cuenta'),
        backgroundColor: const Color.fromRGBO(3, 4, 94, 1.0),
        foregroundColor: Colors.white,
      ),
      body: Container(
        // Usamos los colores de tu paleta
        decoration: const BoxDecoration(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white)) 
                : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginView ? '¡Bienvenido de vuelta!' : 'Crea tu cuenta',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- CAMPO DE NOMBRE (Solo si es Registro) ---
                  if (!_isLoginView)
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Nombre'),
                      enabled: !_isLoading, 
                    ),
                  if (!_isLoginView) const SizedBox(height: 20),

                  // --- CAMPO DE EMAIL ---
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress, 
                    decoration: _buildInputDecoration('Email'), 
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),

                  // --- CAMPO DE CONTRASEÑA ---
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true, 
                    decoration: _buildInputDecoration('Contraseña'),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 40),
                  
                  // --- BOTÓN DE ENVIAR ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(144, 224, 239, 1.0), // Tu paleta
                      foregroundColor: const Color.fromRGBO(3, 4, 94, 1.0), // Tu paleta
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoginView ? 'Ingresar' : 'Registrarme',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- BOTÓN PARA CAMBIAR DE VISTA ---
                  TextButton(
                    onPressed: _isLoading ? null : _toggleView,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: Text(
                      _isLoginView
                          ? '¿No tienes cuenta? Regístrate aquí'
                          : '¿Ya tienes cuenta? Inicia sesión',
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper para construir la decoración de los inputs
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }
}
