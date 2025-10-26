// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _pythonServerUrl = 'http://localhost:5000';
  
  static Future<List<NewsItem>> getPositiveNews() async {
    try {
      final response = await http.get(
        Uri.parse('$_pythonServerUrl/api/news'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NewsItem.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar noticias');
      }
    } catch (e) {
      // Noticias de ejemplo si hay error
      return _getMockNews();
    }
  }
  
  static List<NewsItem> _getMockNews() {
    return [
      const NewsItem(
        title: "Avance en energía solar logra récord de eficiencia",
        description: "Nuevo panel solar alcanza el 45% de eficiencia, marcando un hito en energías renovables.",
        link: "https://example.com/noticia1",
        date: "2024-01-15",
      ),
      const NewsItem(
        title: "Reforestación masiva recupera bosques en América Latina", 
        description: "Proyecto conjunto siembra 10 millones de árboles nativos en la región.",
        link: "https://example.com/noticia2",
        date: "2024-01-14",
      ),
    ];
  }
}

class NewsItem {
  final String title;
  final String description;
  final String link;
  final String date;
  
  const NewsItem({
    required this.title,
    required this.description,
    required this.link,
    required this.date,
  });
  
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['titulo'] ?? '',
      description: json['descripcion'] ?? '',
      link: json['link'] ?? '',
      date: json['fecha'] ?? '',
    );
  }
}