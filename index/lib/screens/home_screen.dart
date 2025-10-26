import 'package:flutter/material.dart';
// ¡Importamos nuestras 3 nuevas pantallas (tabs)!
import 'tabs/home_tab.dart' as home_tab;
import 'tabs/finance_tab.dart' as finance_tab;
import 'tabs/profile_tab.dart';
// ¡Importamos los colores!
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable para saber qué tab está seleccionado
  int _selectedIndex = 0; 

  // Lista de las 3 pantallas que me pediste
  static const List<Widget> _widgetOptions = <Widget>[
    home_tab.HomeTab(),
    finance_tab.FinanceTab(),
    ProfileTab(),
  ];

  // Función que se llama cuando se toca un tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openChatbot() {
    // TODO: Lógica para abrir el chatbot
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo chatbot...'),
        backgroundColor: AppColors.darkestBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Stack para poner el botón de chat
      // encima del contenido de las pestañas.
      body: Stack(
        children: [
          // Contenido principal (cambia según el tab)
          _widgetOptions.elementAt(_selectedIndex),
          
          // --- BOTÓN DEL CHATBOT ---
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _openChatbot,
              backgroundColor: AppColors.darkBlue,
              foregroundColor: AppColors.white,
              tooltip: 'Abrir Chatbot',
              child: const Icon(Icons.chat_bubble),
            ),
          ),
        ],
      ),
      
      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on), 
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkestBlue, // Color del ítem activo
        unselectedItemColor: AppColors.greyText, // Color de ítems inactivos
        onTap: _onItemTapped, // Llama a nuestra función
        backgroundColor: AppColors.white, // Fondo de la barra
        elevation: 10,
        showUnselectedLabels: true,
      ),
    );
  }
}