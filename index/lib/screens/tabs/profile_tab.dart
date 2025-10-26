// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart'; // Importamos colores

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>(); // Key para el formulario
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Para "Nueva Contraseña"

  // Estado para los toggles de pago
  bool _isGooglePayEnabled = true;
  bool _isApplePayEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- ACTUALIZADO ---
  // Carga los datos actuales del usuario en los campos
  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; });
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) _auth.signOut();
        return;
      }

      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (mounted && docSnapshot.exists) {
        final data = docSnapshot.data();
        _nameController.text = data?['name'] ?? '';
        _emailController.text = data?['email'] ?? '';
        
        // Cargar datos de pago
        final payments = data?['payment_methods'] as Map<String, dynamic>?;
        _isGooglePayEnabled = payments?['google_pay_enabled'] ?? true;
        _isApplePayEnabled = payments?['apple_pay_enabled'] ?? false;
      }
    } catch (e) {
      if(mounted) _showErrorSnackBar('Error al cargar datos: ${e.toString()}');
      //print('Error al cargar datos en Perfil: $e');
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // --- ¡¡¡IMPLEMENTADO!!! ---
  // Lógica para guardar los datos
  Future<void> _saveProfile() async {
    // 1. Validar campos
    if (!_formKey.currentState!.validate()) {
      return; // Si la validación falla, no hacer nada
    }

    setState(() { _isLoading = true; });
    
    // Esconder el teclado
    FocusScope.of(context).unfocus();
    
    // Limpiar SnackBars anteriores
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _auth.signOut(); // Si no hay usuario, sacar
        return;
      }
      
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text.trim();

      final userDocRef = _firestore.collection('users').doc(user.uid);
      
      // --- Pasos 2 y 3: Actualizar Firestore ---
      final Map<String, dynamic> updates = {
        'name': newName,
        'email': newEmail, // Actualizamos el email en Firestore también
        'payment_methods': { // Guardamos las opciones de pago
          'google_pay_enabled': _isGooglePayEnabled,
          'apple_pay_enabled': _isApplePayEnabled,
        }
      };
      await userDocRef.update(updates);

      // --- Paso 4: Actualizar email en FirebaseAuth ---
      if (newEmail != user.email) {
        await user.updateEmail(newEmail);
      }

      // --- Paso 5: Actualizar password en FirebaseAuth ---
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
        _passwordController.clear(); // Limpiar el campo de contraseña
      }
      
      // ¡Éxito!
      _showSuccessSnackBar('¡Perfil actualizado con éxito!');

    } on FirebaseAuthException catch (e) {
      // Manejo de errores de Auth (el más común)
      String message;
      if (e.code == 'requires-recent-login') {
        message = 'Esta operación es sensible. Por favor, cierra sesión y vuelve a entrar para guardar estos cambios.';
        // Forzamos el cierre de sesión para que re-autentique
        await _auth.signOut();
      } else if (e.code == 'email-already-in-use') {
        message = 'Ese correo ya está en uso por otra cuenta.';
      } else {
        message = 'Error de autenticación: ${e.message}';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      // Error genérico
      _showErrorSnackBar('Ocurrió un error inesperado: ${e.toString()}');
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // --- FUNCIÓN PARA CERRAR SESIÓN ---
  Future<void> _signOut() async {
    await _auth.signOut();
  }
  
  // --- Helpers para SnackBars ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
      ),
    );
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Configuración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Usamos un Form para la validación
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones
                    children: [
                      // --- FOTO DE PERFIL ---
                      Center(
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.paleBlue,
                              // TODO: Cargar imagen de perfil del usuario
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.mediumBlue,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: AppColors.white),
                                  onPressed: () { /* TODO: Lógica para cambiar foto */ },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- CAMPOS DE TEXTO ---
                      _buildSectionTitle('Información Personal'),
                      _buildProfileTextField(
                        label: 'Nombre',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, ingresa tu nombre.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildProfileTextField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Deshabilitado para edición
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Por favor, ingresa un email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildProfileTextField(
                        label: 'Nueva Contraseña (dejar vacío para no cambiar)',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // --- MÉTODOS DE PAGO ---
                      _buildSectionTitle('Cuentas de Transferencia'),
                      _buildPaymentToggles(),

                      const SizedBox(height: 40),
                      
                      // --- BOTÓN DE GUARDAR ---
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                      ),
                      
                      // --- BOTÓN DE CERRAR SESIÓN (NUEVO) ---
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkBlue,
                          side: const BorderSide(color: AppColors.paleBlue),
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      // ------------------------------------

                      const SizedBox(height: 80), // Padding para el FAB
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper para títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkestBlue,
        ),
      ),
    );
  }

  // Helper para construir los campos de texto
  Widget _buildProfileTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator, // Para la validación
  }) {
    return TextFormField( // Cambiado de TextField a TextFormField
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.darkBlue),
        prefixIcon: Icon(icon, color: AppColors.mediumBlue),
      ),
      validator: validator, // Asignar la función de validación
    );
  }

  // Widget para los toggles de pago
  Widget _buildPaymentToggles() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Google Pay', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Usar como cuenta principal'),
            value: _isGooglePayEnabled, 
            onChanged: (bool value) {
              setState(() {
                _isGooglePayEnabled = value;
                if (value) _isApplePayEnabled = false; // Solo uno puede ser principal
              });
            },
            activeColor: AppColors.darkBlue,
            secondary: const Icon(Icons.payment, color: AppColors.mediumBlue),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Apple Pay', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Usar como cuenta principal'),
            value: _isApplePayEnabled, 
            onChanged: (bool value) {
              setState(() {
                _isApplePayEnabled = value;
                if (value) _isGooglePayEnabled = false; // Solo uno puede ser principal
              });
            },
            activeColor: AppColors.darkBlue,
            secondary: const Icon(Icons.apple, color: AppColors.mediumBlue),
          ),
        ],
      ),
    );
  }
}