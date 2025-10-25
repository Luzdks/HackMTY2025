import 'package:flutter/material.dart';
// Importamos el archivo de la pantalla de inicio para poder navegar a él
import 'home_screen.dart'; 

// -------------------------------------------------------------------
// PANTALLA DE AUTENTICACIÓN (Login / Registro)
// (Este es el mismo código que tenías antes, pero en su propio archivo)
// -------------------------------------------------------------------

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginView = true;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
    });
  }

  void _submit() {
    final String userName = _isLoginView ? _phoneController.text : _nameController.text;

    if (_isLoginView) {
      print('Iniciando sesión con Teléfono: ${_phoneController.text}');
    } else {
      print('Registrando con Nombre: ${_nameController.text}');
    }

    // ¡Navegación!
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // Le decimos que construya 'HomeScreen'
        builder: (context) => HomeScreen(userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginView ? 'Iniciar Sesión' : 'Crear Cuenta'),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginView ? '¡Bienvenido de vuelta!' : 'Crea tu cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  if (!_isLoginView)
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Nombre'),
                    ),
                  if (!_isLoginView) SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('Teléfono'),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: _buildInputDecoration('Contraseña'),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(144, 224, 239, 1.0),
                      foregroundColor: Color.fromRGBO(3, 4, 94, 1.0),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoginView ? 'Ingresar' : 'Registrarme',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: _toggleView,
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
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }
}