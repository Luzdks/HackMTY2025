import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart'; // Importamos colores

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _userName = 'Cargando...';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargamos el nombre del usuario (como antes)
  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) _auth.signOut();
        return;
      }
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (mounted && docSnapshot.exists) {
        setState(() {
          _userName = docSnapshot.data()?['name'] ?? 'Usuario';
        });
      }
    } catch (e) {
      //print('Error al cargar datos en HomeTab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('¡Bienvenido, $_userName!'),
      ),
      // Contenido principal con scroll
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSavingsCard(), // Tarjeta de Ahorros
              const SizedBox(height: 24),
              _buildNewsSection(), // Sección de Noticias
              const SizedBox(height: 80), // Espacio para el botón flotante
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la tarjeta de ahorros
  Widget _buildSavingsCard() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ahorros Totales',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$14,280.50', // Dato de ejemplo
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.darkestBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '+ \$250.10 esta semana',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyText)
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la sección de noticias
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Noticias Relevantes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkestBlue,
          ),
        ),
        const SizedBox(height: 16),
        // Aquí iría un ListView.builder, pero usamos tarjetas estáticas
        _buildNewsCard(
          '¿Es buen momento para invertir en Cetes?',
          'https://placehold.co/600x400/0077B6/FFFFFF?text=Noticia+1',
        ),
        _buildNewsCard(
          'Nuevas funciones de ahorro en tu app',
          'https://placehold.co/600x400/0096C7/FFFFFF?text=Noticia+2',
        ),
        _buildNewsCard(
          'Cómo la IA está cambiando las finanzas',
          'https://placehold.co/600x400/00B4D8/FFFFFF?text=Noticia+3',
        ),
      ],
    );
  }

  // Widget para una tarjeta de noticia individual
  Widget _buildNewsCard(String title, String imageUrl) {
    return Card(
      clipBehavior: Clip.antiAlias, // Para redondear la imagen
      child: InkWell(
        onTap: () {
          // TODO: Lógica para abrir la noticia
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              // Fallback por si la imagen falla
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
