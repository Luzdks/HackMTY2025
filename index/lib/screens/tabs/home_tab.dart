import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../../services/news_service.dart'; // Importamos el servicio de noticias

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _userName = 'Cargando...';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // Variables para las noticias
  List<NewsItem> _news = [];
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNews(); // Cargar noticias al iniciar
  }

  // Cargamos el nombre del usuario
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

  // Cargar noticias desde el servicio
  Future<void> _loadNews() async {
    try {
      final news = await NewsService.getPositiveNews();
      setState(() {
        _news = news;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
      });
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
              _buildNewsSection(), // Sección de Noticias (ACTUALIZADA)
              const SizedBox(height: 80), // Espacio para el botón flotante
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la tarjeta de ahorros (SIN CAMBIOS)
  Widget _buildSavingsCard() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$1,280.50', // Dato de ejemplo
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

  // Widget para la sección de noticias (ACTUALIZADO)
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Noticias Positivas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkestBlue,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoadingNews ? null : _loadNews,
              tooltip: 'Actualizar noticias',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Estado de carga
        if (_isLoadingNews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: AppColors.darkBlue,
              ),
            ),
          )
        
        // Si no hay noticias
        else if (_news.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.article, size: 48, color: AppColors.greyText),
                  SizedBox(height: 16),
                  Text(
                    'No hay noticias disponibles',
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        
        // Lista de noticias
        else
          Column(
            children: _news.map((newsItem) => _buildNewsCard(newsItem)).toList(),
          ),
      ],
    );
  }

  // Widget para una tarjeta de noticia individual (ACTUALIZADO)
  Widget _buildNewsCard(NewsItem newsItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Lógica para abrir la noticia completa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Abriendo: ${newsItem.title}'),
              backgroundColor: AppColors.darkBlue,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                newsItem.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkestBlue,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Descripción
              Text(
                newsItem.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyText,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Fecha y enlace
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    newsItem.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyText,
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Leer más ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 14, color: AppColors.darkBlue),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}