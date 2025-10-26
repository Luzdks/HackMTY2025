import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- NUEVOS IMPORTS ---
import 'dart:convert'; // Para decodificar el JSON
import 'package:flutter/services.dart' show rootBundle; // Para cargar el archivo local
import 'package:url_launcher/url_launcher.dart'; // Para abrir los enlaces
// --- FIN DE NUEVOS IMPORTS ---

import '../../theme/app_colors.dart';
import '../../../services/news_service.dart'; // Importamos el servicio de noticias (contiene la clase NewsItem)


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

  // Cargamos el nombre del usuario (SIN CAMBIOS)
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

  // --- FUNCIÓN _loadNews MODIFICADA ---
  // Cargar noticias desde el archivo JSON local
  Future<void> _loadNews() async {
    // Indicamos que estamos cargando
    if (mounted) {
      setState(() {
        _isLoadingNews = true;
      });
    }

    try {
      // 1. Cargar el contenido del archivo JSON como un String
      // Asegúrate que la ruta 'assets/noticias.json' sea correcta
      final String jsonString = await rootBundle.loadString('python_server/noticias.json');
      
      // 2. Decodificar el String JSON a una lista dinámica
      final List<dynamic> jsonList = json.decode(jsonString);

      // 3. Mapear la lista de JSON a nuestra lista de NewsItem
      final List<NewsItem> news = jsonList.map((jsonItem) {
        return NewsItem(
          title: jsonItem['titulo'] ?? 'Sin título',
          description: jsonItem['descripcion'] ?? 'Sin descripción',
          link: jsonItem['link'] ?? '',
          
          // Tu JSON no tiene fecha, pero la clase NewsItem la requiere.
          // Usamos un valor temporal o un string vacío.
          date: 'Fecha no disponible', 
        );
      }).toList();

      // 4. Actualizar el estado con las noticias cargadas
      if (mounted) {
        setState(() {
          _news = news;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      // print('Error al cargar noticias locales: $e');
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
          _news = []; // Dejar la lista vacía si hay un error
        });
      }
    }
  }
  // --- FIN DE LA FUNCIÓN MODIFICADA ---

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

  // Widget para la sección de noticias (SIN CAMBIOS, PERO _loadNews afectará su estado)
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

  // --- WIDGET _buildNewsCard MODIFICADO ---
  // Se actualizó el 'onTap' para abrir el enlace
  Widget _buildNewsCard(NewsItem newsItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          // Lógica para abrir el enlace de la noticia
          if (newsItem.link.isEmpty) return; // No hacer nada si no hay link

          final Uri url = Uri.parse(newsItem.link);
          
          if (await canLaunchUrl(url)) {
            // Abrir en el navegador externo
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            // Mostrar error si no se puede abrir
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo abrir el enlace'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
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
                    newsItem.date, // Mostrará "Fecha no disponible"
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
  // --- FIN DEL WIDGET MODIFICADO ---
}