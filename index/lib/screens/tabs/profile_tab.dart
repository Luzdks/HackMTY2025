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
        _nameController.text = docSnapshot.data()?['name'] ?? '';
        _emailController.text = docSnapshot.data()?['email'] ?? '';
        // TODO: Cargar también el estado de Google/Apple Pay desde Firestore
      }
    } catch (e) {
      //print('Error al cargar datos en Perfil: $e');
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // Lógica para guardar los datos
  Future<void> _saveProfile() async {
    // TODO: Agregar lógica para guardar los datos
    // 1. Validar campos
    // 2. Actualizar 'name' y 'email' en Firestore
    // 3. Actualizar 'isGooglePayEnabled' y 'isApplePayEnabled' en Firestore
    // 4. Actualizar 'email' en FirebaseAuth (requiere re-autenticación)
    // 5. Actualizar 'password' en FirebaseAuth (requiere re-autenticación)

    setState(() { _isLoading = true; });
    // Simular guardado
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardando cambios... (Lógica de guardado no implementada)'),
          backgroundColor: AppColors.mediumBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Configuración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                    const SizedBox(height: 20),
                    _buildProfileTextField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileTextField(
                      label: 'Nueva Contraseña',
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      obscureText: true,
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
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
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
                    const SizedBox(height: 80), // Padding para el FAB
                  ],
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.darkBlue),
        prefixIcon: Icon(icon, color: AppColors.mediumBlue),
      ),
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
            activeThumbColor: AppColors.darkBlue,
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
            activeThumbColor: AppColors.darkBlue,
            secondary: const Icon(Icons.apple, color: AppColors.mediumBlue),
          ),
        ],
      ),
    );
  }

  // Método para cerrar sesión
  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}